import 'package:flutter/material.dart';


enum _ChatStep { terms, intro, activeChat }

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  _ChatStep _currentStep = _ChatStep.terms;
  final TextEditingController _chatMessageController = TextEditingController();
  final List<String> _chatMessages = [];


  final String _userName = "User";

  void _progressToStep(_ChatStep nextStep) {
    setState(() {
      _currentStep = nextStep;
    });
  }

  void _sendMessage() {
    if (_chatMessageController.text.isNotEmpty) {
      setState(() {
        _chatMessages.add("User: ${_chatMessageController.text}");
        // Simulate a bot response
        _chatMessages.add("Wiseman: You said '''${_chatMessageController.text}'''. How can I help further?");
        _chatMessageController.clear();
      });
    }
  }

  @override
  void dispose() {
    _chatMessageController.dispose();
    super.dispose();
  }

  Widget _buildTermsStep(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms and conditions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {

            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Hi, my name is Wiseman.',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  '''By proceeding, you consent to the terms and conditions for using the Onit AI Assistant. 
Data Handling: Your conversation data will be handled in accordance with our privacy policy.
OTP Security: Never share One-Time Passwords (OTPs) with anyone, including Onit or bank staff.
Live Agent Escalation: If Onit cannot resolve your query, you may be connected to a live agent. 
Further details can be found in our full terms of service document.
                  ''',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
                // Navigate back to Inbox Hub
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);

                }
              },
            ),
            ElevatedButton(
              child: const Text('CONTINUE'),
              onPressed: () => _progressToStep(_ChatStep.intro),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroStep(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Message Centre'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _progressToStep(_ChatStep.terms), // Go back to T&C
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Placeholder for illustration
            Icon(
              Icons.chat_bubble_outline, // Replace with your illustration
              size: 100,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 24),
            const Text(
              'Chat with us.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Chat with our AI assistant Wiseman, or our dedicated team of bankers for selected queries.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('CHAT WITH US', style: TextStyle(fontSize: 16)),
              onPressed: () => _progressToStep(_ChatStep.activeChat),
            ),
            const SizedBox(height: 20),
            // Optional: If you want to show a snippet of the inbox below
            // Text("Note: Inbox list might be shown here in a more complex layout.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildActiveChatStep(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with us'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _progressToStep(_ChatStep.intro), // Go back to Intro
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('END CHAT', style: TextStyle(color: Colors.white)),
            onPressed: () {
              // Reset to terms, or pop, or navigate to inbox
              setState(() {
                _chatMessages.clear();
                _currentStep = _ChatStep.terms;
              });
              // if (Navigator.canPop(context)) Navigator.pop(context);
            },
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    "Hi $_userName, I'm Wiseman, your online banking assistant.",
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                const SizedBox(height: 10),
                // Menu options (tap-to-select cards/buttons)
                _buildMenuOption(
                  context,
                  icon: Icons.credit_card,
                  title: 'Card Limits',
                  onTap: () { /* TODO: Handle Card Limits tap */ setState(() { _chatMessages.add("Wiseman: How can I help with Card Limits?"); }); },
                ),
                _buildMenuOption(
                  context,
                  icon: Icons.autorenew,
                  title: 'Debit Order Reversal',
                  onTap: () { /* TODO: Handle Debit Order Reversal tap */ setState(() { _chatMessages.add("Wiseman: Tell me about the debit order you want to reverse."); }); },
                ),
                _buildMenuOption(
                  context,
                  icon: Icons.pin,
                  title: 'Forgot PIN',
                  onTap: () { /* TODO: Handle Forgot PIN tap */ setState(() { _chatMessages.add("Wiseman: I can help with PIN related queries."); }); },
                ),
                _buildMenuOption(
                  context,
                  icon: Icons.report_problem,
                  title: 'Report Fraud',
                  onTap: () { /* TODO: Handle Report Fraud tap */ setState(() { _chatMessages.add("Wiseman: Let's secure your account. What happened?"); }); },
                ),
                _buildMenuOption(
                  context,
                  icon: Icons.folder_open,
                  title: 'Documents',
                  onTap: () { /* TODO: Handle Documents tap */ setState(() { _chatMessages.add("Wiseman: Which documents are you looking for?"); }); },
                ),
                const SizedBox(height: 10),
                Text(
                  "You can ask a question like '''I want to reverse a debit order'''...",
                  style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                final isUserMessage = _chatMessages[index].startsWith("User:");
                return Align(
                  alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
                    decoration: BoxDecoration(
                      color: isUserMessage ? Theme.of(context).primaryColor.withOpacity(0.8) : Colors.grey[300],
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Text(
                      _chatMessages[index],
                      style: TextStyle(color: isUserMessage ? Colors.white : Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _chatMessageController,
                    decoration: const InputDecoration(
                        hintText: 'Write your message here...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0)
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentStep) {
      case _ChatStep.terms:
        return _buildTermsStep(context);
      case _ChatStep.intro:
        return _buildIntroStep(context);
      case _ChatStep.activeChat:
        return _buildActiveChatStep(context);
    }
  }
}
