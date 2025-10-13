import 'package:flutter/gestures.dart'; // For TapGestureRecognizer in RichText
import 'package:flutter/material.dart';
import 'success_otp_screen_page.dart'; // IMPORTANT: Import for navigation
import 'withdrawal_deatils_modal.dart'; // Import the new modal



// Data class to hold arguments passed to this screen
class WithdrawalConfirmationArgs {
  final String amount;
  final String accountName;
  final String accountNumber;
  final String cellphoneNumber;
  final String withdrawalPoint;

  WithdrawalConfirmationArgs({
    required this.amount,
    required this.accountName,
    required this.accountNumber,
    required this.cellphoneNumber,
    this.withdrawalPoint = "AgencyPlus Agent or FNB ATM",
  });
}

class ConfirmationPage extends StatefulWidget {
  // Renamed for clarity
  final WithdrawalConfirmationArgs args;

  const ConfirmationPage({super.key, required this.args});

  // static const routeName = '/withdrawal-confirmation';

  @override
  State<ConfirmationPage> createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage> {
  bool _termsAccepted = false;
  bool _isProcessing = false; // To show loading state and prevent double taps

  void _onViewTerms() {
    print("View Terms of Use tapped");
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: const Text("Terms of Use"),
            content: const SingleChildScrollView(
              child: Text(
                  "Here are the detailed terms and conditions for cash withdrawals...\n\n"
                      "1. You are responsible for the security of your withdrawal voucher.\n"
                      "2. Limits apply as per regulatory guidelines and bank policy.\n"
                      "3. Ensure the receiving cellphone number is correct; transactions to incorrect numbers may not be reversible.\n"
                // ... more terms
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("CLOSE"),
              ),
            ],
          ),
    );
  }

  Future<void> _onConfirmPressed() async {
    if (_isProcessing) return; // Prevent multiple submissions

    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please accept the terms of use to continue."),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Simulate backend call and OTP generation
    await Future.delayed(const Duration(seconds: 2));
    final String generatedOtp = "13579"; // Example OTP
    final bool apiSuccess = true;

    if (!mounted) return;

    if (apiSuccess) {
      // Show withdrawal details modal before navigating to OTP success screen
      final confirmed = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => WithdrawalDetailsModal(
          amount: widget.args.amount,
          accountName: widget.args.accountName,
          accountNumber: widget.args.accountNumber,
          cellphoneNumber: widget.args.cellphoneNumber,
          otp: generatedOtp,
        ),
      );
      if (confirmed == true && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessOtpScreen(
              args: WithdrawalSuccessArgs(
                otp: generatedOtp,
                amount: widget.args.amount,
                accountName: widget.args.accountName,
                accountNumber: widget.args.accountNumber,
                cellphoneNumber: widget.args.cellphoneNumber,
              ),
            ),
          ),
        );
      } else {
        setState(() { _isProcessing = false; });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Withdrawal request failed. Please try again later.')),
      );
      setState(() { _isProcessing = false; });
    }
  }

  void _onClosePressed() {
    if (_isProcessing) return; // Don't allow close if processing
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
          tooltip: 'Back to Setup',
        ),
        title: const Text("Withdraw Cash"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _isProcessing ? null : _onClosePressed,
            tooltip: 'Close Withdrawal',
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: theme.brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Please confirm your withdrawal details:",
              style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryRow(
                        context, "Withdrawal amount:", "R${widget.args.amount}",
                        isAmount: true),
                    const Divider(height: 20),
                    _buildSummaryRow(context, "From:", widget.args.accountName),
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                        context, "At:", widget.args.withdrawalPoint),
                    const SizedBox(height: 8),
                    _buildSummaryRow(context, "Cellphone Number:",
                        widget.args.cellphoneNumber),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Terms of Use",
              style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _onViewTerms,
              style: TextButton.styleFrom(padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,),
              child: Text("View terms of use", style: TextStyle(
                color: theme.colorScheme.primary,
                decoration: TextDecoration.underline,
                decorationColor: theme.colorScheme.primary,),),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Checkbox(
                  value: _termsAccepted,
                  onChanged: _isProcessing ? null : (bool? value) {
                    setState(() {
                      _termsAccepted = value ?? false;
                    });
                  },
                  activeColor: theme.colorScheme.primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _isProcessing ? null : () {
                      setState(() {
                        _termsAccepted = !_termsAccepted;
                      });
                    },
                    child: Text("I have read and accept the terms of use.",
                      style: theme.textTheme.bodyMedium,),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDisclaimerText(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0).copyWith(bottom: MediaQuery
            .of(context)
            .viewInsets
            .bottom + 16.0),
        child: ElevatedButton(
          onPressed: (_termsAccepted && !_isProcessing)
              ? _onConfirmPressed
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            disabledBackgroundColor: Colors.grey[700],
            disabledForegroundColor: Colors.grey[400],
          ),
          child: _isProcessing
              ? const SizedBox(width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
              : const Text("CONFIRM"),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value,
      {bool isAmount = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.hintColor),),
          const SizedBox(width: 16),
          Expanded(
            child: Text(value, textAlign: TextAlign.right,
              style: isAmount ? theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold, color: theme.colorScheme.primary)
                  : theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimerText(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),),
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant),
          children: [
            WidgetSpan(child: Icon(Icons.security_outlined, size: 16,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8))),
            const TextSpan(text: " Security Reminder: "),
            const TextSpan(
                text: "Keep your withdrawal voucher and PIN safe. Do not share it with anyone. "),
            const TextSpan(
                text: "Withdrawal limits may apply as per bank policy. For help, contact support.\n\n"),
            WidgetSpan(child: Icon(Icons.info_outline, size: 16,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8))),
            const TextSpan(text: " Important: "),
            const TextSpan(
                text: "Ensure all details are correct before confirming. Transactions may not be reversible once processed."),
          ],
        ),
      ),
    );
  }
}