const functions = require("firebase-functions");
const admin = require("firebase-admin");
const stripe = require("stripe")(functions.config().stripe.secret_test_key);

admin.initializeApp();

// When a user is created, register them with Stripe
exports.createStripeCustomer = functions.firestore
    .document("users/{userId}")
    .onCreate(async (snap, context) => {
      const data = snap.data();
      const email = data.email;

      try {
        // Create a customer in Stripe
        const customer = await stripe.customers.create({email: email});

        // Update Firestore with Stripe customer ID
        await admin.firestore()
            .collection("users")
            .doc(context.params.userId)
            .update({
              stripeId: customer.id,
            });

        console.log(`Created Stripe customer for ${email}: ${customer.id}`);
        return null;
      } catch (error) {
        console.error(`Error creating Stripe customer for ${email}:`, error);
        throw error;
      }
    });

exports.createEphemeralKey = functions.https.onCall(async (data, context) => {
  const customerId = data.customer_id;
  const stripeVersion = data.stripe_version;
  const uid = context.auth.uid;

  if (uid === null) {
    console.log("Illegal access attempt due to unauthenticated user");
    throw new functions.https.HttpsError(
        "permission-denied",
        "Illegal access attempt.",
    );
  }

  return stripe.ephemeralKeys.create(
      {customer: customerId},
      {stripe_version: stripeVersion},
  ).then((key) => {
    return key;
  }).catch((err) => {
    console.log(err);
    throw new functions.https.HttpsError(
        "internal",
        "Unable to create ephemeral key",
    );
  });
});
