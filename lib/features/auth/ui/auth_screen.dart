import 'package:flutter/material.dart';

import '../../../shared/constants.dart';
import '../../../utils/show_snackbar.dart';
import 'controllers/auth_screen_controller.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthScreenProvider.of(context);

    final formKey = GlobalKey<FormState>();

    final usernameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    String getUsername() => usernameController.text.trim();
    String getEmail() => emailController.text.trim();
    String getPassword() => passwordController.text;

    void submitAuth() {
      if (auth.isSignUp) {
        auth
            .signUp(
              username: getUsername(),
              email: getEmail(),
              password: getPassword(),
            )
            .catchError(
              (error) => showSnackbar(
                context: context,
                message: error.toString(),
              ),
            );
      } else if (auth.isResetPassword) {
        auth
            .resetPassword(
              email: getEmail(),
            )
            .catchError(
              (error) => showSnackbar(
                context: context,
                message: error.toString(),
              ),
            );
      } else {
        auth
            .signIn(
              email: getEmail(),
              password: getPassword(),
            )
            .catchError(
              (error) => showSnackbar(
                context: context,
                message: error.toString(),
              ),
            );
      }
    }

    return WillPopScope(
      onWillPop: () async {
        if (!auth.isSignIn) {
          auth.setSignIn();
          return false;
        }

        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: !auth.isSignIn
              ? IconButton(
                  onPressed: Navigator.of(context).maybePop,
                  icon: const Icon(Icons.arrow_back),
                )
              : null,
          title: Text(
            auth.isResetPassword
                ? 'Сброс пароля'
                : auth.isSignUp
                    ? 'Новый ${Constants.appName} ID'
                    : '${Constants.appName} ID',
          ),
        ),
        body: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (auth.isSignUp)
                  TextFormField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Ник на 4PDA',
                      hintText: 'Ваш ник на 4PDA',
                      prefixIcon: Icon(Icons.account_circle_outlined),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.name,
                    validator: (username) => username?.isEmpty == true
                        ? 'Введите свой ник на 4PDA'
                        : null,
                  ),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Почта',
                    hintText: 'example@domain.com',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (email) =>
                      email?.isEmpty == true ? 'Введите свою почту' : null,
                ),
                if (!auth.isResetPassword)
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Пароль',
                      hintText: auth.isSignUp ? 'Не менее 6 символов' : null,
                      prefixIcon: const Icon(Icons.password),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    validator: (password) => password?.isEmpty == true
                        ? 'Пароль не должен быть пустым'
                        : null,
                  ),
                if (auth.isSignUp)
                  TextFormField(
                    controller: confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Подтвердите пароль',
                      hintText: 'Пароли должны совпадать',
                      prefixIcon: Icon(Icons.password),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    validator: (confirmPassword) =>
                        confirmPassword != getPassword()
                            ? 'Пароли должны совпадать'
                            : null,
                  ),
                FilledButton.icon(
                  onPressed: submitAuth,
                  icon: Icon(
                    auth.isSignUp
                        ? Icons.person_add
                        : auth.isResetPassword
                            ? Icons.password
                            : Icons.login,
                  ),
                  label: Text(
                    auth.isSignUp
                        ? 'Создать аккаунт'
                        : auth.isResetPassword
                            ? 'Сбросить пароль'
                            : 'Войти',
                  ),
                ),
                if (auth.isSignIn)
                  OutlinedButton.icon(
                    onPressed: auth.setResetPassword,
                    icon: const Icon(Icons.password),
                    label: const Text('Забыли пароль?'),
                  ),
                if (auth.isSignUp)
                  const Text(
                    'Нажимая кнопку "Создать аккаунт", вы принимаете условия использования приложения ${Constants.appName}',
                    style: TextStyle(fontSize: 12.0),
                    textAlign: TextAlign.center,
                  ),
              ]
                  .map(
                    (widget) => Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 12.0,
                      ),
                      child: widget,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        floatingActionButton: auth.isSignIn
            ? FloatingActionButton.extended(
                onPressed: auth.setSignUp,
                icon: const Icon(Icons.person_add),
                label: const Text('Создать аккаунт'),
              )
            : null,
      ),
    );
  }
}
