import 'package:flutter/material.dart';
import 'dart:async'; // For Timer
import 'withdrawal_deatils_modal.dart'; // IMPORTANT: Import for Modal

// Data class to hold arguments passed to this screen
class WithdrawalSuccessArgs {
  final String otp;
  final String amount;
  final String accountName;
  final String accountNumber;
  final String cellphoneNumber;

  WithdrawalSuccessArgs({
    required this.otp,
    required this.amount,
    required this.accountName,
    required this.accountNumber,
    required this.cellphoneNumber,
  });
}

class SuccessOtpScreen extends StatefulWidget {
  // Renamed for clarity
  final WithdrawalSuccessArgs args;

  const SuccessOtpScreen({super.key, required this.args});

  // static const routeName = '/withdrawal-success-otp';

  @override
  State<SuccessOtpScreen> createState() => _SuccessOtpScreenState();
}

class _SuccessOtpScreenState extends State<SuccessOtpScreen> {
  Timer? _otpExpiryTimer;
  int _otpExpirySeconds = 30 * 60; // 30 minutes

  @override
  void initState() {
    super.initState();
    _startOtpExpiryTimer();
  }

  void _startOtpExpiryTimer() {
    _otpExpiryTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { // Ensure widget is still mounted before setState
        timer.cancel();
        return;
      }
      if (_otpExpirySeconds > 0) {
        setState(() {
          _otpExpirySeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          // UI update for expired OTP already handled by _formattedExpiryTime
        });
      }
    });
  }

  String get _formattedExpiryTime {
    if (_otpExpirySeconds <= 0) return "Expired";
    int minutes = _otpExpirySeconds ~/ 60;
    int seconds = _otpExpirySeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(
        2, '0')}";
  }

  void _onViewDetailsPressed() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Theme
          .of(context)
          .cardColor,
      // Ensures modal bg matches theme
      builder: (BuildContext context) {
        return WithdrawalDetailsModal(
          amount: widget.args.amount,
          accountName: widget.args.accountName,
          accountNumber: widget.args.accountNumber,
          cellphoneNumber: widget.args.cellphoneNumber,
          otp: widget.args.otp,
        );
      },
    );
  }

  void _onFinishPressed() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  void dispose() {
    _otpExpiryTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async {
        _onFinishPressed();
        return false; // We handle the pop explicitly
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: _onFinishPressed,
            tooltip: 'Finish',
          ),
          title: const Text("Withdrawal Successful"),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _onFinishPressed, // Close also finishes the flow
              tooltip: 'Finish & Close',
            ),
          ],
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: theme.brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.check_circle_outline_rounded,
                    color: Colors.green.shade600, size: 80),
                const SizedBox(height: 24),
                Text("Thank you!",
                  style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700),
                  textAlign: TextAlign.center,),
                const SizedBox(height: 8),
                Text("Your request to withdraw R${widget.args
                    .amount} has been processed successfully.",
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,),
                const SizedBox(height: 32),
                Text("Your One-Time PIN (OTP) is:",
                  style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.hintColor), textAlign: TextAlign.center,),
                const SizedBox(height: 8),
                Text(widget.args.otp,
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                    color: theme.colorScheme.primary,),
                  textAlign: TextAlign.center,),
                const SizedBox(height: 12),
                Text(
                  _otpExpirySeconds > 0
                      ? "This OTP will expire in: $_formattedExpiryTime"
                      : "OTP has expired. Please initiate a new withdrawal if needed.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                      color: _otpExpirySeconds > 0
                          ? theme.colorScheme.error
                          : theme.hintColor,
                      fontWeight: _otpExpirySeconds > 0
                          ? FontWeight.w600
                          : FontWeight.normal
                  ), textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer.withOpacity(
                        0.4), borderRadius: BorderRadius.circular(8),),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.message_outlined, size: 20,
                          color: theme.colorScheme.onSecondaryContainer),
                      const SizedBox(width: 8),
                      Expanded(child: Text(
                        "The OTP has also been sent via inContact to your banking app notifications.",
                        style: theme.textTheme.bodySmall?.copyWith(color: theme
                            .colorScheme.onSecondaryContainer),
                        textAlign: TextAlign.center,),
                      ),
                    ],
                  ),
                ),
                //const Spacer(),
                const SizedBox(height: 80), // Space for bottom buttons
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0).copyWith(bottom: MediaQuery
              .of(context)
              .viewInsets
              .bottom + 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: _onViewDetailsPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  foregroundColor: theme.colorScheme.primary,
                  minimumSize: const Size(double.infinity, 50),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                          color: theme.colorScheme.primary, width: 1.5)),
                  elevation: 0,
                ),
                child: const Text("VIEW DETAILS"),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _onFinishPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("FINISH"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}