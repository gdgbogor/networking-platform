part of '../camera_page.dart';

class _Camera extends StatefulWidget {
  const _Camera();

  @override
  State<_Camera> createState() => _CameraState();
}

class _CameraState extends State<_Camera> {
  List<XFile> _mediaFileList = [];
  // Image? _pickedImage;

  void _setImageFileListFromFile(XFile? value) {
    _mediaFileList = value == null ? [] : <XFile>[value];
  }

  dynamic _pickImageError;
  bool isVideo = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      // ImagePickerWeb.
      // // ;
      // final pickedImage = await ImagePickerWeb.getImageInfo;
      // if (pickedImage == null) throw Exception('Ambil foto gagal');
      // _pickedImage = Image.memory(pickedImage.data!);

      final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxHeight: 1080,
        maxWidth: 1080,
      );
      setState(() {
        _setImageFileListFromFile(pickedFile);
      });
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
    }
  }

  void _clearImage() {
    setState(() {
      _mediaFileList.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Builder(
          builder: (context) {
            if (_mediaFileList.isNotEmpty) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.passthrough,
                  alignment: Alignment.center,
                  children: [
                    Image.network(
                      _mediaFileList[0].path,
                      fit: BoxFit.cover,
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                            ),
                            onPressed: _clearImage,
                            child: const Icon(
                              Icons.clear,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else if (_pickImageError != null) {
              return Text(
                'Pick image error: $_pickImageError',
                textAlign: TextAlign.center,
              );
            } else {
              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 300,
                  child: Stack(
                    fit: StackFit.passthrough,
                    children: [
                      Image.network(
                        'https://media4.giphy.com/media/xT9IgslYmfbTXP9vA4/giphy.gif?cid=ecf05e47jbugp4ywu5uailxcau6mz6mm0tx200zb6tz6yec1&ep=v1_gifs_search&rid=giphy.gif&ct=g',
                        colorBlendMode: BlendMode.darken,
                        fit: BoxFit.cover,
                      ),
                      const Positioned.fill(
                        child: ColoredBox(color: Colors.black54),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 64),
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 100,
                        ),
                      ),
                      const Positioned.fill(
                        child: Center(
                          child: Text(
                            '\n\n\nAmbil foto',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _pickImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade800,
            disabledBackgroundColor: Colors.grey.shade400,
          ),
          onPressed: _mediaFileList.isEmpty
              ? null
              : () {
                  context
                      .read<PhotoBloc>()
                      .add(PhotoEventSave(_mediaFileList[0]));
                  context.router.push(const PostRoute());
                },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _mediaFileList.isEmpty ? 'Ambil foto dahulu' : 'Lanjut',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

// class _DetectedPlate extends StatelessWidget {
//   const _DetectedPlate();

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<ScannerSpotBloc, ScannerSpotState>(
//       builder: (context, state) {
//         if (state.detectedPlateList == null) {
//           return const SizedBox.shrink();
//         }
//         return GridView.builder(
//           itemCount: state.detectedPlateList!.length,
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             mainAxisSpacing: 8,
//             crossAxisSpacing: 8,
//             crossAxisCount: 2,
//             childAspectRatio: 3,
//           ),
//           itemBuilder: (context, index) {
//             final plate = state.detectedPlateList![index];
//             return ElevatedButton(
//               // height: 50,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 padding: const EdgeInsets.all(12),
//               ),
//               onPressed: () {
//                 context.read<ScannerSpotBloc>().add(
//                       CameraSelectPlate(index: index),
//                     );
//               },
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     '${plate.a} ${plate.b} ${plate.c}',
//                     maxLines: 1,
//                     style: const TextStyle(
//                       fontSize: 17,
//                       fontWeight: FontWeight.w900,
//                     ),
//                     textScaleFactor: ScaleSize.textScaleFactor(context),
//                   ),
//                   const Icon(Icons.edit)
//                 ],
//               ),
//               // color: Colors.red,
//             );
//           },
//         );
//       },
//     );
//   }
// }
