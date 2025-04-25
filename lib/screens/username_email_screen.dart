import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swift_mobile/inc/auth.dart';
import 'package:swift_mobile/inc/update_email_username.dart';
import 'package:swift_mobile/uitls/my_appbar.dart';

class UsernameEmailScreen extends StatefulWidget {
  const UsernameEmailScreen({super.key, required int userId});

  @override
  State<UsernameEmailScreen> createState() => _UsernameEmailScreenState();
}

class _UsernameEmailScreenState extends State<UsernameEmailScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final auth = Provider.of<Auth>(context, listen: false);
    if (auth.user != null) {
      setState(() {
        _usernameController.text = auth.user!['name'] ?? '';
        _emailController.text = auth.user!['email'] ?? '';
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();

    setState(() => _isLoading = true);

    try {
      await UpdateEmailUsername.updateUser(
        username: username,
        email: email,
        context: context,
      );
    } catch (e) {
      // Errors are already handled by UpdateEmailUsername's modal dialogs
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(context),
      bottomNavigationBar: _buildUpdateButton(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    _buildTextField(
                      controller: _usernameController,
                      hintText: "Username",
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _emailController,
                      hintText: "Email",
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                ),
              ),
            ),
            // _buildUpdateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: hintText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildUpdateButton() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(left: 10, right: 10, bottom: 20),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.purple),
          minimumSize: WidgetStateProperty.all(const Size(300, 70)),
          padding: WidgetStateProperty.all(const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          )),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Update',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
