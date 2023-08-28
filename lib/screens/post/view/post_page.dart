import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_challenge/app/app.dart';

import 'package:photo_challenge/screens/post/post.dart';
import 'package:photo_challenge/screens/wall_self/wall_self.dart';
import 'package:photo_challenge/shared/photo/photo_bloc.dart';

@RoutePage()
class PostPage extends StatelessWidget {
  const PostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PostBloc(),
      child: const PostView(),
    );
  }
}

class PostView extends StatelessWidget {
  const PostView({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<PostBloc>();
    final appBloc = context.read<AppBloc>();
    final capturedImage = context.read<PhotoBloc>().state.capturedImage;
    return BlocListener<PostBloc, PostState>(
      listener: (context, state) {
        if (state.isUploadSuccess) {
          context.router.popUntilRoot();
          context.read<WallSelfBloc>().add(
                LoadPhotos(
                  orderNumber: context.read<AppBloc>().state.orderNumber,
                  participantName: appBloc.state.participantName!,
                ),
              );
        }
      },
      child: Scaffold(
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 500),
              child: AnimatedSize(
                curve: Curves.easeOutExpo,
                duration: const Duration(milliseconds: 500),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        alignment: Alignment.bottomLeft,
                        fit: StackFit.passthrough,
                        children: [
                          BlocBuilder<PostBloc, PostState>(
                            builder: (context, state) {
                              String path;
                              if (capturedImage == null) {
                                path = 'https://picsum.photos/1200/1440';
                              } else {
                                path = capturedImage.path;
                              }
                              return Image.network(
                                path,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                          BlocBuilder<PostBloc, PostState>(
                            bloc: bloc,
                            builder: (context, state) {
                              return SizedBox(
                                height: 80,
                                child: ListView.builder(
                                  padding: const EdgeInsets.only(
                                    left: 8,
                                    right: 16,
                                  ),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: state.chosenNames.length,
                                  itemBuilder: (_, index) {
                                    final item =
                                        state.chosenNames.elementAt(index);
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Chip(
                                        onDeleted: () {
                                          log('pencet');
                                          bloc.add(
                                            RemoveName(
                                              orderNumber: item.orderNumber,
                                            ),
                                          );
                                        },
                                        backgroundColor: Colors.white,
                                        labelPadding: const EdgeInsets.all(8),
                                        label: Text(
                                          item.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(
                                                color: Colors.grey.shade800,
                                              ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Autocomplete<({String orderNumber, String name})>(
                      onSelected: (option) {
                        bloc.add(
                          ChooseName(
                            orderNumber: option.orderNumber,
                          ),
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4,
                            color: Colors.white,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxHeight: 130,
                                maxWidth: 200,
                              ),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final option = options.elementAt(index);
                                  return InkWell(
                                    onTap: () {
                                      onSelected(option);
                                    },
                                    child: Builder(
                                      builder: (_) {
                                        final highlight =
                                            AutocompleteHighlightedOption.of(
                                                  context,
                                                ) ==
                                                index;
                                        if (highlight) {
                                          SchedulerBinding.instance
                                              .addPostFrameCallback(
                                                  (Duration timeStamp) {
                                            Scrollable.ensureVisible(
                                              context,
                                              alignment: 0.5,
                                            );
                                          });
                                        }
                                        return Container(
                                          color: Colors.grey.shade200,
                                          padding: const EdgeInsets.all(16),
                                          child: Text(option.name),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        return context.read<PostBloc>().state.resultNames;
                      },
                      // onSelected: onSelected,
                      fieldViewBuilder: (
                        BuildContext context,
                        TextEditingController fieldTextEditingController,
                        FocusNode fieldFocusNode,
                        VoidCallback onFieldSubmitted,
                      ) {
                        return BlocBuilder<PostBloc, PostState>(
                          buildWhen: (previous, current) {
                            if (previous.chosenNames != current.chosenNames) {
                              fieldTextEditingController.clear();
                            }
                            return true;
                          },
                          builder: (context, state) {
                            if (state.isUploading) {
                              return const SizedBox.shrink();
                            }
                            if (state.resultNames.isNotEmpty) {
                              fieldTextEditingController
                                ..text = fieldTextEditingController.text
                                ..selection = TextSelection(
                                  baseOffset:
                                      fieldTextEditingController.text.length,
                                  extentOffset:
                                      fieldTextEditingController.text.length,
                                );
                            }

                            return TextField(
                              enabled: !state.isUploading,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                hintText: 'Nama peserta',
                                helperText: 'Gunakan satu nama',
                                label: const Text('Tandai peserta'),
                                suffixIcon: state.isLoadingNames
                                    ? const Padding(
                                        padding: EdgeInsets.only(right: 8),
                                        child: CircularProgressIndicator(),
                                      )
                                    : IconButton(
                                        onPressed: () {
                                          fieldTextEditingController.clear();
                                          fieldFocusNode.requestFocus();
                                        },
                                        icon: const Icon(Icons.close),
                                      ),
                                suffixIconConstraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                              ),
                              controller: fieldTextEditingController,
                              focusNode: fieldFocusNode,
                              onSubmitted: (value) {
                                onFieldSubmitted();
                                fieldTextEditingController.clear();
                                fieldFocusNode.requestFocus();
                              },
                              onChanged: (value) {
                                context.read<PostBloc>()
                                  ..add(const StartEditing())
                                  ..add(
                                    EditName(name: value),
                                  );
                              },
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<PostBloc, PostState>(
                      bloc: bloc,
                      builder: (context, state) {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade800,
                            disabledBackgroundColor: Colors.grey.shade500,
                          ),
                          onPressed: state.isUploading &&
                                      capturedImage != null ||
                                  state.chosenNames.isEmpty
                              ? null
                              : () {
                                  bloc.add(
                                    UploadPhoto(
                                      photo: capturedImage!,
                                      orderNumber: appBloc.state.orderNumber,
                                      name: appBloc.state.participantName!,
                                    ),
                                  );
                                },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: state.isUploading
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Memposting ',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge!
                                            .copyWith(color: Colors.white),
                                      ),
                                      const CircularProgressIndicator(),
                                    ],
                                  )
                                : Text(
                                    state.chosenNames.isEmpty
                                        ? 'Tandai peserta minimal satu'
                                        : 'Post',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .copyWith(color: Colors.white),
                                  ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
