import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_challenge/app/app.dart';

import 'package:photo_challenge/screens/wall_self/wall_self.dart';

@RoutePage()
class WallSelfPage extends StatelessWidget {
  const WallSelfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _WallSelfView();
  }
}

class _WallSelfView extends StatefulWidget {
  const _WallSelfView();

  @override
  State<_WallSelfView> createState() => _WallSelfViewState();
}

const List<String> avaTier = [
  'https://firebasestorage.googleapis.com/v0/b/photo-challenge-keras.appspot.com/o/assets%2Fdownload.jpeg?alt=media&token=ba5a496f-2a79-4a28-a530-861e219876b2',
  'https://firebasestorage.googleapis.com/v0/b/photo-challenge-keras.appspot.com/o/assets%2Fprof_keras_intermediate.png?alt=media&token=737ebb80-097c-4590-883e-d77d305746b6',
  'https://firebasestorage.googleapis.com/v0/b/photo-challenge-keras.appspot.com/o/assets%2Fprof_keras_advanced.png?alt=media&token=b721522d-7473-4c97-bfd6-46ff153b5cff',
  'https://firebasestorage.googleapis.com/v0/b/photo-challenge-keras.appspot.com/o/assets%2Fprof_keras_expert.png?alt=media&token=31bca04f-8a77-4713-b30d-9682b0a5b8ad',
];

class _WallSelfViewState extends State<_WallSelfView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    final appBloc = context.read<AppBloc>();
    super.initState();
    context.read<WallSelfBloc>().add(
          LoadPhotos(
            orderNumber: context.read<AppBloc>().state.orderNumber,
            participantName: appBloc.state.participantName!,
          ),
        );
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.position.pixels) {
        context.read<WallSelfBloc>().add(
              LoadMorePhotos(
                participantName: appBloc.state.participantName!,
              ),
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appBloc = context.read<AppBloc>();
    return BlocBuilder<WallSelfBloc, WallSelfState>(
      builder: (context, state) {
        return Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: BlocBuilder<WallSelfBloc, WallSelfState>(
                builder: (context, state) {
                  final photoList = state.photoList;
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<WallSelfBloc>().add(
                            LoadPhotos(
                              orderNumber:
                                  context.read<AppBloc>().state.orderNumber,
                              participantName: appBloc.state.participantName!,
                            ),
                          );
                      final stream = context.read<WallSelfBloc>().stream;
                      return stream
                          .firstWhere((WallSelfState state) => !state.isLoading)
                          .then((state) => !state.isLoading);
                    },
                    notificationPredicate: (notification) {
                      return notification.depth == 0;
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(0, 12, 0, 48),
                      itemCount: photoList == null ? 2 : photoList.length + 2,
                      itemBuilder: (_, index) {
                        if (index == 0) {
                          return Column(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 210,
                                    height: 210,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 7,
                                      value: 1,
                                      color: Colors.red.shade600,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 200,
                                    width: 200,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(999),
                                      child: Image.network(
                                        avaTier.elementAt(
                                          state.networkCount < 2
                                              ? 0
                                              : state.networkCount < 3
                                                  ? 1
                                                  : state.networkCount < 4
                                                      ? 2
                                                      : 3,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                context.read<AppBloc>().state.participantName ??
                                    'Peserta',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              IntrinsicHeight(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('${state.photoCount} Foto'),
                                    const Flexible(child: VerticalDivider()),
                                    Text('${state.networkCount} Network')
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        }
                        if (photoList == null ||
                            index == photoList.length + 1) {
                          return SizedBox(
                            height: 100,
                            child: Center(
                              child: AnimatedCrossFade(
                                firstChild: Text(
                                  !state.isLoading && photoList!.isEmpty
                                      ? 'Mulai post foto bersama kamu'
                                      : state.hasNewPhotos
                                          ? 'Lihat lagi... 👀'
                                          : 'Ayo post foto lagi',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                secondChild: const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                crossFadeState:
                                    !state.isLoading && photoList != null
                                        ? CrossFadeState.showFirst
                                        : CrossFadeState.showSecond,
                                sizeCurve: Curves.easeInOutExpo,
                                duration: const Duration(milliseconds: 300),
                              ),
                            ),
                          );
                        }
                        final photo = photoList.elementAt(index - 1);
                        final tagged = state.taggedList!.elementAt(index - 1);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Stack(
                            fit: StackFit.passthrough,
                            children: [
                              Image(
                                image: photo.image,
                                fit: BoxFit.cover,
                              ),
                              Positioned.fill(
                                child: Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 80,
                                        child: ListView.builder(
                                          padding: const EdgeInsets.only(
                                            left: 8,
                                            right: 16,
                                          ),
                                          scrollDirection: Axis.horizontal,
                                          itemCount: tagged.length,
                                          itemBuilder: (context, index) {
                                            final name =
                                                tagged.elementAt(index);
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                left: 8,
                                              ),
                                              child: Chip(
                                                backgroundColor: Colors.white,
                                                labelPadding:
                                                    const EdgeInsets.all(8),
                                                label: Text(
                                                  name,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium!
                                                      .copyWith(
                                                        color: Colors
                                                            .grey.shade800,
                                                      ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
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
    );
  }
}
