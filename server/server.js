require('dotenv').config({ path: 'file.env' });
const express = require('express');
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

app.post('/create-payment-sheet', async (req, res) => {
  try {
    const { amount, currency, customerId } = req.body;
    
    // 1. Créer ou récupérer le client Stripe
    const customer = customerId 
      ? await stripe.customers.retrieve(customerId)
      : await stripe.customers.create();

    // 2. Créer le Payment Intent
    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount,
      currency: currency,
      customer: customer.id,
      automatic_payment_methods: { enabled: true },
    }, {
      apiVersion: '2025-04-30.basil' 
    });

    // 3. Créer la clé éphémère
    const ephemeralKey = await stripe.ephemeralKeys.create(
      { customer: customer.id },
      { apiVersion: '2025-04-30.basil' }
    );

    // 4. Réponse
    res.json({
      paymentIntent: paymentIntent.client_secret,
      ephemeralKey: ephemeralKey.secret,
      customer: customer.id,
    });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.listen(process.env.PORT, () => {
  console.log(`Server running on port ${process.env.PORT}`);
});