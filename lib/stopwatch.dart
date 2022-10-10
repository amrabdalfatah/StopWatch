import 'dart:async';

import 'package:flutter/material.dart';

class StopWatch extends StatefulWidget {
  static const route = '/stopwatch';

  const StopWatch({Key? key}) : super(key: key);

  @override
  State<StopWatch> createState() => _StopWatchState();
}

class _StopWatchState extends State<StopWatch> {
  int seconds = 0;
  Timer? timer;

  bool isTicking = false;
  int milliseconds = 0;

  final laps = <int>[];

  final itemHeight = 60.0;
  final scrollController = ScrollController();

  void _lap() {
    setState(() {
      laps.add(milliseconds);
      milliseconds = 0;
    });

    scrollController.animateTo(
      itemHeight * laps.length,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeIn,
    );
  }

  void _startTimer() {
    timer = Timer.periodic(
      const Duration(milliseconds: 100),
      (timer) {
        seconds = seconds + 1;
        setState(() {
          milliseconds += 100;
        });
      },
    );
    setState(() {
      seconds = 0;
      isTicking = true;
      laps.clear();
    });
  }

  void _stopTimer(BuildContext context) {
    if (!isTicking) {
      return;
    }
    timer!.cancel();
    setState(() {
      isTicking = false;
    });

    final controller =
        showBottomSheet(context: context, builder: _buildRunCompleteSheet);

    Future.delayed(const Duration(seconds: 5)).then((_) => controller.close());
  }

  Widget _buildRunCompleteSheet(BuildContext context) {
    final totalRuntime = laps.fold(milliseconds, (total, lap) => total + lap);
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Container(
        color: Theme.of(context).cardColor,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Run Finished!',
                style: textTheme.headline6,
              ),
              Text('Total Run Time is ${_secondsText(totalRuntime)}.'),
            ],
          ),
        ),
      ),
    );
  }

  String _secondsText(int milliseconds) {
    final seconds = milliseconds / 1000;
    return '$seconds seconds';
  }

  @override
  Widget build(BuildContext context) {
    String name = ModalRoute.of(context)!.settings.arguments.toString();
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Column(
        children: [
          Expanded(child: _buildCounter(context)),
          Expanded(child: _buildLapDisplay()),
        ],
      ),
    );
  }

  Widget _buildCounter(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Lap ${laps.length + 1}',
            style: Theme.of(context)
                .textTheme
                .subtitle1!
                .copyWith(color: Colors.white),
          ),
          Text(
            _secondsText(milliseconds),
            style: Theme.of(context)
                .textTheme
                .headline5!
                .copyWith(color: Colors.white),
          ),
          const SizedBox(
            height: 20,
          ),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white)),
          onPressed: isTicking ? null : _startTimer,
          child: const Text('Start'),
        ),
        const SizedBox(
          width: 20,
        ),
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.yellow),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
          ),
          onPressed: isTicking ? _lap : null,
          child: const Text('Lap'),
        ),
        const SizedBox(
          width: 20,
        ),
        Builder(
          builder: (context) => TextButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                foregroundColor:
                    MaterialStateProperty.all<Color>(Colors.white)),
            onPressed: isTicking ? () => _stopTimer(context) : null,
            child: const Text('Stop'),
          ),
        ),
      ],
    );
  }

  Widget _buildLapDisplay() {
    return Scrollbar(
      child: ListView.builder(
        controller: scrollController,
        itemExtent: itemHeight,
        itemCount: laps.length,
        itemBuilder: (context, index) {
          final milliseconds = laps[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 50),
            title: Text('Lap ${index + 1}'),
            trailing: Text(_secondsText(milliseconds)),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }
}
