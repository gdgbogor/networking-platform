import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_challenge/app/app.dart';
import 'package:photo_challenge/router/app_router.dart';

@RoutePage()
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const LandingView();
  }
}

class LandingView extends StatefulWidget {
  const LandingView({super.key});

  @override
  State<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView> {
  final _firestore = FirebaseFirestore.instance;
  final _textController = TextEditingController();
  var _isValid = false;
  var _isCheckingTicket = false;
  var _isTicketValid = true;

  Future<void> _submitOrderNumber() async {
    setState(() {
      _isCheckingTicket = true;
    });
    final userDocId = await _checkTiketIsValid();
    if (userDocId != null) {
      await _doSignInAnon(userDocId);
      if (mounted) {
        await context.router.replace(const WallRoute());
      }
      return;
    }
    setState(() {
      _isCheckingTicket = false;
      _isTicketValid = false;
    });
  }

  Future<Map<String, dynamic>?> _checkTiketIsValid() async {
    try {
      final result = await _firestore
          .collection('userList')
          .where('orderNumber', isEqualTo: _textController.text)
          .get();
      if (result.docs.isEmpty) {
        return null;
      } else {
        return {...result.docs.first.data(), 'id': result.docs.first.id};
      }
    } catch (e) {
      log('message error $e');
    }

    return null;
  }

  Future<void> _doSignInAnon(Map<String, dynamic> userDoc) async {
    // final cred2 = cred.credential?.token;
    if (mounted) {
      context.read<AppBloc>().add(
            UpdateOrderNumber(
              orderNumber: _textController.text,
              participantName: userDoc['name'] as String,
              isAdmin: userDoc['isAdmin'] as bool? ?? false,
            ),
          );
    }

    await _firestore.collection('userList').doc(userDoc['id'] as String).set(
      {
        'orderNumber': _textController.text,
      },
      SetOptions(merge: true),
    );
  }

  void _showGuide() {
    showDialog<void>(
      context: context,
      builder: (context) {
        // return const Center(
        //   child: Text('Guide'),
        //   // https://firebasestorage.googleapis.com/v0/b/photo-challenge-keras.appspot.com/o/assets%2FWhatsApp%20Image%202023-08-23%20at%207.46.09%20PM.jpeg?alt=media&token=5c5cec77-6a4d-4cba-b9ff-f51c1d562fa8
        // );
        return AlertDialog(
          titlePadding: const EdgeInsets.all(8),
          title: CachedNetworkImage(
            progressIndicatorBuilder: (context, url, progress) => const Center(
              child: CircularProgressIndicator(),
            ),
            imageUrl:
                'https://firebasestorage.googleapis.com/v0/b/photo-challenge-keras.appspot.com/o/assets%2FWhatsApp%20Image%202023-08-23%20at%207.46.09%20PM.jpeg?alt=media&token=7219a87a-2d8e-4b44-9a3e-d4265b472c8c',
          ),
          content: const Text('Temukan di Tiketmu, di bagian Order Number'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(32, 32, 32, 500),
            children: [
              const SizedBox(height: 50),
              Text(
                'Welcome to GDG Bogor\nKeras Community Day\nNetwork Challenge',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: Colors.white),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  CachedNetworkImage(
                    height: 300,
                    width: 500,
                    imageUrl:
                        'https://firebasestorage.googleapis.com/v0/b/photo-challenge-keras.appspot.com/o/assets%2Fcircuits-electronics-digital-art-wallpaper-preview.jpg?alt=media&token=dc367ca7-75b7-4970-b1f2-259e31e16675',
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: CachedNetworkImage(
                        width: 100,
                        height: 100,
                        imageUrl:
                            'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ae/Keras_logo.svg/360px-Keras_logo.svg.png',
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                'Networking, but make it fun',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(color: Colors.white),
              ),
              const SizedBox(height: 50),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    controller: _textController,
                    onChanged: (value) {
                      if (!_isTicketValid) {
                        _isTicketValid = true;
                      }
                      setState(() {
                        _isValid = RegExp(r'^[A-Za-z0-9]{13}$').hasMatch(value);
                      });
                    },
                    onFieldSubmitted: (value) {
                      if (_textController.text.isEmpty || _isCheckingTicket) {
                        _submitOrderNumber();
                      }
                    },
                    decoration: InputDecoration(
                      label: const Text('Order Number'),
                      border: const OutlineInputBorder(),
                      filled: true,
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      hintText: 'GOOGA12345678',
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AnimatedSize(
                curve: Curves.easeOutExpo,
                duration: const Duration(milliseconds: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_textController.text.isNotEmpty &&
                        _isValid &&
                        _isTicketValid)
                      Padding(
                        padding: const EdgeInsets.all(2),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade800,
                            disabledBackgroundColor: Colors.grey.shade400,
                          ),
                          onPressed:
                              _textController.text.isEmpty || _isCheckingTicket
                                  ? null
                                  : _submitOrderNumber,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: _isCheckingTicket
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : Text(
                                    'Masuk',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(color: Colors.white),
                                  ),
                          ),
                        ),
                      )
                    else if (_textController.text.isNotEmpty && !_isValid)
                      const Text(
                        'Sesuaikan Order Number',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      )
                    else if (!_isTicketValid)
                      const Text(
                        'Order Number tidak ditemukan',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      )
                    else
                      const Text(
                        'Isi Order Number',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    OutlinedButton(
                      onPressed: _showGuide,
                      child: const Text('Cara menemukan order number'),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '''Dengan mengikuti Network Challenge ini, kamu setuju untuk networking bersama''',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: Colors.white),
              ),
              const SizedBox(height: 16),
              Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: SizedBox(
                      width: 100,
                      child: CachedNetworkImage(
                        imageUrl:
                            'https://firebasestorage.googleapis.com/v0/b/photo-challenge-keras.appspot.com/o/assets%2F1_v0LmFs2Uvc8DJQyKXb0qWw%402x.png?alt=media&token=44bd17d0-0801-41b0-9ce6-bf77356803fa',
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
