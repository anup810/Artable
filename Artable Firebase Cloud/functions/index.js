const functions = require("firebase-functions");
const admin = require("firebase-admin");
const stripe = require("stripe")(functions.config().stripe.secret_test_key);

admin.initializeApp();

// Create charge
// When a user is created, register them with Stripe
exports.createStripeCustomer = functions.firestore.document("users/{userId}")
    .onCreate(async (snap, context) => {
      const data = snap.data();
      const email = data["email"];

      console.log(data);
      const customer = await stripe.customers.create({email: email});
      return admin.firestore().collection("users").doc(data["id"])
          .update({stripeId: customer.id});
    });
exports.createCharge = functions.https.onCall(async (data, context) => {
  const customerId = data.customer_id;
  const paymentMethodId = data.payment_method_id;
  const totalAmount = data.total_amount;
  const idempotency = data.idempotency;

  // Input validation
  if (!customerId) {
    throw new functions.https.HttpsError("invalid-argument",
        "Missing customer ID");
  }
  if (!paymentMethodId) {
    throw new functions.https.HttpsError("invalid-argument",
        "Missing payment method ID");
  }
  if (!totalAmount) {
    throw new functions.https.HttpsError("invalid-argument",
        "Missing amount");
  }

  try {
    // First, verify the payment method belongs to the customer
    const paymentMethod = await stripe.paymentMethods.retrieve(paymentMethodId);
    if (paymentMethod.customer && paymentMethod.customer !== customerId) {
      throw new functions.https.HttpsError(
          "failed-precondition",
          "Payment method does not belong to this customer",
      );
    }

    // Attach payment method to customer if not already attached
    if (!paymentMethod.customer) {
      await stripe.paymentMethods.attach(paymentMethodId, {
        customer: customerId,
      });
    }

    // Create the payment intent with expanded error handling
    const intent = await stripe.paymentIntents.create({
      payment_method: paymentMethodId,
      customer: customerId,
      amount: totalAmount,
      currency: "usd",
      confirm: true,
      payment_method_types: ["card"],
      description: `Charge for customer ${customerId}`,
      metadata: {
        idempotencyKey: idempotency,
      },
    }, {
      idempotencyKey: idempotency,
    });

    console.log("Payment Intent Created:", intent.id);
    console.log("Status:", intent.status);
    return {
      success: true,
      intentId: intent.id,
      status: intent.status,
    };
  } catch (err) {
    console.error("Stripe Error:", {
      type: err.type,
      message: err.message,
      code: err.code,
      decline_code: err.decline_code,
      param: err.param,
    });

    // Map Stripe errors to appropriate HTTP errors
    if (err.type === "StripeCardError") {
      throw new functions.https.HttpsError("failed-precondition",
          `Card error: ${err.message}`);
    } else if (err.type === "StripeInvalidRequestError") {
      throw new functions.https.HttpsError("invalid-argument",
          `Invalid request: ${err.message}`);
    } else {
      throw new functions.https.HttpsError("internal",
          `Payment processing failed: ${err.message}`);
    }
  }
});

// Create Ephemeral Key
exports.createEphemeralKey = functions.https.onCall(async (data, context) => {
  const customerId = data.customer_id;
  const stripeVersion = data.stripe_version;

  try {
    const key = await stripe.ephemeralKeys.create(
        {customer: customerId},
        {apiVersion: stripeVersion},
    );
    return key;
  } catch (err) {
    console.log(err);
    throw new functions.https.HttpsError(
        "internal",
        "Unable to create ephemeral key: " + err.message,
    );
  }
});
