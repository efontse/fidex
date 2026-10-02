const config = require('../config/config');

class PaymentService {
  /**
   * Charge customer using external Payment Gateway API
   * @param {Object} params
   * @param {number} params.amount
   * @param {string} params.method - 'card', 'mobile_money', 'bank_transfer'
   * @param {number} params.orderId
   * @param {Object} [params.metadata]
   */
  static async charge({ amount, method = 'card', orderId, metadata = {} }) {
    console.log(`[PaymentService] Initiating charge of $${amount} via ${method} for Order #${orderId}`);

    // Simulate external payment provider processing
    const isDeclineSimulation = Number(amount) === 999.99; // Test trigger for declined payment simulation

    if (isDeclineSimulation) {
      return {
        success: false,
        status: 'failed',
        reason: 'Payment declined: Insufficient funds or card limits.',
        providerReference: `txn_declined_${Date.now()}`
      };
    }

    const providerReference = `farmora_txn_${Date.now()}_${Math.random().toString(36).substring(2, 9).toUpperCase()}`;

    return {
      success: true,
      status: 'completed',
      providerReference,
      amount: Number(amount),
      method,
      chargedAt: new Date().toISOString()
    };
  }

  /**
   * Check status of a transaction with the external Payment Gateway
   * @param {string} providerReference
   */
  static async getStatus(providerReference) {
    console.log(`[PaymentService] Checking external status for reference: ${providerReference}`);
    if (providerReference.includes('declined')) {
      return { status: 'failed', providerReference };
    }
    return {
      status: 'completed',
      providerReference,
      verifiedAt: new Date().toISOString()
    };
  }
}

module.exports = PaymentService;
