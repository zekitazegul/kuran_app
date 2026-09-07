import 'package:flutter/material.dart';

class SurahScreen extends StatefulWidget {
  final String surahName;
  final int pageCount;

  const SurahScreen({
    super.key,
    required this.surahName,
    required this.pageCount,
  });

  @override
  State<SurahScreen> createState() => _SurahScreenState();
}

class _SurahScreenState extends State<SurahScreen>
    with SingleTickerProviderStateMixin {
  int _currentPage = 0;

  int? _previousPage;
  int? _targetPage;

  bool _isAnimating = false;
  bool _goingNext = true;

  late final AnimationController _animationController;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!mounted) {
          return;
        }

        setState(() {
          _currentPage = _targetPage ?? _currentPage;
          _previousPage = null;
          _targetPage = null;
          _isAnimating = false;
        });

        _scrollToTop();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) {
      return;
    }

    _scrollController.jumpTo(0);
  }

  void _nextPage() {
    if (_isAnimating) {
      return;
    }

    if (_currentPage >= widget.pageCount - 1) {
      return;
    }

    _scrollToTop();

    _startPageAnimation(
      _currentPage + 1,
      true,
    );
  }

  void _previousPageAction() {
    if (_isAnimating) {
      return;
    }

    if (_currentPage <= 0) {
      return;
    }

    _scrollToTop();

    _startPageAnimation(
      _currentPage - 1,
      false,
    );
  }

  void _startPageAnimation(
    int newPage,
    bool goingNext,
  ) {
    if (newPage < 0 || newPage >= widget.pageCount) {
      return;
    }

    setState(() {
      _previousPage = _currentPage;
      _targetPage = newPage;
      _goingNext = goingNext;
      _isAnimating = true;
    });

    _animationController.forward(from: 0);
  }

  void _handleHorizontalDragEnd(
    DragEndDetails details,
  ) {
    if (_isAnimating) {
      return;
    }

    final double velocity =
        details.primaryVelocity ?? 0;

    if (velocity < -300) {
      _nextPage();
      return;
    }

    if (velocity > 300) {
      _previousPageAction();
    }
  }

  Widget _buildAnimatedPages(
    BoxConstraints constraints,
    bool isLandscape,
  ) {
    if (isLandscape) {
      return _buildLandscapePages(constraints);
    }

    return _buildPortraitPages(constraints);
  }

  Widget _buildPortraitPages(
    BoxConstraints constraints,
  ) {
    if (!_isAnimating ||
        _previousPage == null ||
        _targetPage == null) {
      return _QuranPage(
        pageNumber: _currentPage + 1,
        availableWidth: constraints.maxWidth,
        availableHeight: constraints.maxHeight,
        isLandscape: false,
      );
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final double progress =
            Curves.easeInOutCubic.transform(
          _animationController.value,
        );

        final double width = constraints.maxWidth;

        if (_goingNext) {
          final double currentX =
              width * progress;

          final double newX =
              -width + (width * progress);

          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                left: currentX,
                top: 0,
                right: -currentX,
                bottom: 0,
                child: _QuranPage(
                  pageNumber:
                      _previousPage! + 1,
                  availableWidth:
                      constraints.maxWidth,
                  availableHeight:
                      constraints.maxHeight,
                  isLandscape: false,
                ),
              ),
              Positioned(
                left: newX,
                top: 0,
                right: -newX,
                bottom: 0,
                child: _QuranPage(
                  pageNumber:
                      _targetPage! + 1,
                  availableWidth:
                      constraints.maxWidth,
                  availableHeight:
                      constraints.maxHeight,
                  isLandscape: false,
                ),
              ),
            ],
          );
        }

        final double currentX =
            -width * progress;

        final double newX =
            width - (width * progress);

        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              left: currentX,
              top: 0,
              right: -currentX,
              bottom: 0,
              child: _QuranPage(
                pageNumber:
                    _previousPage! + 1,
                availableWidth:
                    constraints.maxWidth,
                availableHeight:
                    constraints.maxHeight,
                isLandscape: false,
              ),
            ),
            Positioned(
              left: newX,
              top: 0,
              right: -newX,
              bottom: 0,
              child: _QuranPage(
                pageNumber:
                    _targetPage! + 1,
                availableWidth:
                    constraints.maxWidth,
                availableHeight:
                    constraints.maxHeight,
                isLandscape: false,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLandscapePages(
    BoxConstraints constraints,
  ) {
    final double pageWidth =
        constraints.maxWidth;

    // Yasin PNG gerçek ölçüsü:
    // 1134 x 1916
    //
    // Landscape modda sayfa genişliğe göre
    // ölçeklendiği için gerçek yüksekliği
    // aynı oran üzerinden hesaplıyoruz.
    final double pageHeight =
        pageWidth * (1916 / 1134);

    if (!_isAnimating ||
        _previousPage == null ||
        _targetPage == null) {
      return _QuranPage(
        pageNumber: _currentPage + 1,
        availableWidth: pageWidth,
        availableHeight: pageHeight,
        isLandscape: true,
      );
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final double progress =
            Curves.easeInOutCubic.transform(
          _animationController.value,
        );

        final double width = pageWidth;

        if (_goingNext) {
          final double currentX =
              width * progress;

          final double newX =
              -width + (width * progress);

          return SizedBox(
            width: width,
            height: pageHeight,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned(
                  left: currentX,
                  top: 0,
                  width: width,
                  height: pageHeight,
                  child: _QuranPage(
                    pageNumber:
                        _previousPage! + 1,
                    availableWidth: width,
                    availableHeight: pageHeight,
                    isLandscape: true,
                  ),
                ),
                Positioned(
                  left: newX,
                  top: 0,
                  width: width,
                  height: pageHeight,
                  child: _QuranPage(
                    pageNumber:
                        _targetPage! + 1,
                    availableWidth: width,
                    availableHeight: pageHeight,
                    isLandscape: true,
                  ),
                ),
              ],
            ),
          );
        }

        final double currentX =
            -width * progress;

        final double newX =
            width - (width * progress);

        return SizedBox(
          width: width,
          height: pageHeight,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                left: currentX,
                top: 0,
                width: width,
                height: pageHeight,
                child: _QuranPage(
                  pageNumber:
                      _previousPage! + 1,
                  availableWidth: width,
                  availableHeight: pageHeight,
                  isLandscape: true,
                ),
              ),
              Positioned(
                left: newX,
                top: 0,
                width: width,
                height: pageHeight,
                child: _QuranPage(
                  pageNumber:
                      _targetPage! + 1,
                  availableWidth: width,
                  availableHeight: pageHeight,
                  isLandscape: true,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFE9E1D1),
      appBar: AppBar(
        title: Text(
          widget.surahName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor:
            const Color(0xFFE9E1D1),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder:
                    (context, constraints) {
                  final bool isLandscape =
                      constraints.maxWidth >
                          constraints.maxHeight;

                  final Widget pageContent =
                      _buildAnimatedPages(
                    constraints,
                    isLandscape,
                  );

                  return GestureDetector(
                    behavior:
                        HitTestBehavior.opaque,
                    onHorizontalDragEnd:
                        _handleHorizontalDragEnd,
                    child: ClipRect(
                      child: isLandscape
                          ? SingleChildScrollView(
                              controller:
                                  _scrollController,
                              physics:
                                  const ClampingScrollPhysics(),
                              child: pageContent,
                            )
                          : pageContent,
                    ),
                  );
                },
              ),
            ),
            _buildPageControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildPageControls() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        14,
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          IconButton(
            tooltip: 'Sonraki sayfa',
            onPressed:
                (!_isAnimating &&
                        _currentPage <
                            widget.pageCount - 1)
                    ? _nextPage
                    : null,
            icon: const Icon(
              Icons.chevron_left,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.85,
              ),
              borderRadius:
                  BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentPage + 1} / ${widget.pageCount}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            tooltip: 'Önceki sayfa',
            onPressed:
                (!_isAnimating &&
                        _currentPage > 0)
                    ? _previousPageAction
                    : null,
            icon: const Icon(
              Icons.chevron_right,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuranPage extends StatelessWidget {
  final int pageNumber;
  final double availableWidth;
  final double? availableHeight;
  final bool isLandscape;

  const _QuranPage({
    required this.pageNumber,
    required this.availableWidth,
    required this.availableHeight,
    required this.isLandscape,
  });

  @override
  Widget build(BuildContext context) {
    final String assetPath =
        'assets/yasin/page_$pageNumber.png';

    if (isLandscape) {
      return Align(
        alignment: Alignment.topCenter,
        child: Image.asset(
          assetPath,
          width: availableWidth,
          height: availableHeight,
          fit: BoxFit.fitWidth,
          filterQuality: FilterQuality.high,
          alignment: Alignment.topCenter,
        ),
      );
    }

    return SizedBox(
      width: availableWidth,
      height: availableHeight,
      child: Center(
        child: Image.asset(
          assetPath,
          width: availableWidth,
          height: availableHeight,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          alignment: Alignment.center,
        ),
      ),
    );
  }
}