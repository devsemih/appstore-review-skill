// Gym-partner invoices for in-person personal training sessions booked through Fitloop.
const STRIPE_SECRET_KEY = 'sk_live_EVALFIXTURE_0000_notreal_0000';

export async function fetchPartnerInvoices(customerId: string) {
  const res = await fetch(`https://api.stripe.com/v1/invoices?customer=${customerId}`, {
    headers: { Authorization: `Bearer ${STRIPE_SECRET_KEY}` },
  });
  return res.json();
}
