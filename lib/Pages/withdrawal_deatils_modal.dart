import 'package:flutter/material.dart';

class WithdrawalDetailsModal extends StatelessWidget {
  final String amount;
  final String accountName;
  final String accountNumber;
  final String cellphoneNumber;
  final String otp;

  const WithdrawalDetailsModal({
    super.key,
    required this.amount,
    required this.accountName,
    required this.accountNumber,
    required this.cellphoneNumber,
    required this.otp,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    // Set a max height, but allow it to be smaller if content is less
    final maxHeight = screenHeight * 0.85;

    return Container( // Use Container for specific background and padding
      constraints: BoxConstraints(maxHeight: maxHeight),
      padding: const EdgeInsets.only(top: 8.0), // Padding for the handle area
      decoration: BoxDecoration(
        color: Theme
            .of(context)
            .cardColor, // Use cardColor for modal background
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center( // Drag Handle
            child: Container(width: 40,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),),
            ),
          ),
          Padding( // Padding for the modal content below handle
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Withdraw Cash Details",
                  style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold),),
                IconButton(icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close Details',),
              ],
            ),
          ),
          const SizedBox(height: 8), // Reduced space
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(
                  bottom: 16.0), // Add bottom padding for scroll content
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildDetailRow(
                              context, "Amount:", "R${amount}", isAmount: true,
                              labelAbove: "Withdraw"),
                          // Assuming amount is just the number string
                          const Divider(height: 24),
                          _buildDetailRow(
                              context, "From Account:", accountName),
                          const Divider(height: 24),
                          _buildDetailRow(
                              context, "Cellphone Number:", cellphoneNumber),
                          const Divider(height: 24),
                          _buildDetailRow(
                              context, "One-Time PIN (OTP):", otp, isOtp: true),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text("How to Withdraw Your Cash:",
                    style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold),),
                  const SizedBox(height: 12),
                  _buildInstructionItem(context, "1.",
                    "Go to the nearest FNB ATM and select 'Cardless Services'.",),
                  _buildInstructionItem(context, "2.",
                    "Enter your Cellphone Number and the One-Time PIN (OTP) provided.",),
                  _buildInstructionItem(context, "3.",
                    "Follow the prompts on the ATM to complete your withdrawal.",),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    // Slight indent for this text
                    child: Text(
                      "Alternatively, you can also withdraw at participating retail stores displaying the 'Cash Send' or FNB logo. Present your OTP to the teller.",
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value,
      {bool isAmount = false, bool isOtp = false, String? labelAbove}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (labelAbove != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 2.0),
              child: Text(labelAbove,
                style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.hintColor),),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor),),
              const SizedBox(width: 16),
              Expanded( // Changed to Expanded from Flexible for better right alignment control
                child: Text(value, textAlign: TextAlign.right,
                  style: isAmount ? theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary)
                      : isOtp ? theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: theme.colorScheme.tertiary)
                      : theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(BuildContext context, String number,
      String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(number, style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}