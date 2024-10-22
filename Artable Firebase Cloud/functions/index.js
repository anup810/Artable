const functions = require("firebase-functions");
const admin = require("firebase-admin");
const stripe = require("stripe")(functions.config().stripe.secret_test_key);

admin.initializeApp();

// Create charge
exports.createCharge = functions.https.onCall(async (data, context) => {
  const customerId = data.customer_id;
  const paymentMethodId = data.payment_method_id;
  const totalAmount = data.total_amount;
  const idempotency = data.idempotency;

  try {
    const intent = await stripe.paymentIntents.create(
        {
          payment_method: paymentMethodId,
          customer: customerId,
          amount: totalAmount,
          currency: "usd",
          confirm: true,
          payment_method_types: ["card"],
        },
        {idempotency_key: idempotency},
    );

    console.log("Charge Success: ", intent);
    return intent;
  } catch (err) {
    console.log(err);
    throw new functions.https.HttpsError(
        "internal",
        "Unable to create charge: " + err.message,
    );
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
