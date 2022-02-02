import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/poll.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/services/polls_database.dart';
import 'package:hs_connect/shared/inputDecorations.dart';
import 'package:hs_connect/shared/pixels.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

class PollView extends StatefulWidget {
  final Poll poll;
  final DocumentReference currUserRef;
  final Post post;

  const PollView({Key? key, required this.poll, required this.currUserRef, required this.post}) : super(key: key);

  @override
  _PollViewState createState() => _PollViewState();
}

class _PollViewState extends State<PollView> {
  int? voted;
  int maxVotes = 0;
  int totalVotes = 0;
  List<int> choicesVotes = [];

  @override
  void initState() {
    widget.poll.votes.forEach((key, value) {
      if (value.contains(widget.currUserRef) && mounted) {
        setState(() => voted = key);
      }
      if (value.length > maxVotes && mounted) {
        setState(() => maxVotes = value.length);
      }
      if (mounted) {
        setState(() => totalVotes += value.length);
      }
    });
    for (int i = 0; i < widget.poll.choices.length; i++) {
      choicesVotes.add(widget.poll.votes[i]!.length);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final hp = Provider.of<HeightPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5 * hp),
            side: BorderSide(
              color: colorScheme.onError,
              width: 1 * hp,
            ),
          ),
        ),
        padding: EdgeInsets.all(10 * hp),
        margin: EdgeInsets.only(top: 20 * hp),
        child: ListView.builder(
          itemCount: widget.poll.choices.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return PollChoiceView(
                voted: voted,
                text: widget.poll.choices[index],
                votePercentage: choicesVotes[index] / totalVotes,
                index: index,
                numChoiceVotes: choicesVotes[index],
                onVote: () async {
                  if (mounted) {
                    setState(() {
                      choicesVotes[index] += 1;
                      totalVotes += 1;
                      if (choicesVotes[index] > maxVotes) {
                        maxVotes = choicesVotes[index];
                      }
                      voted = index;
                    });
                    PollsDatabaseService _polls = PollsDatabaseService();
                    if (!(await _polls.alreadyVoted(pollRef: widget.poll.pollRef, userRef: widget.currUserRef))) {
                      _polls.vote(pollRef: widget.poll.pollRef, userRef: widget.currUserRef, choice: index, post: widget.post);
                    }
                  }
                });
          },
        ));
  }
}

class PollChoiceView extends StatefulWidget {
  final int? voted;
  final String text;
  final double votePercentage;
  final VoidFunction onVote;
  final int index;
  final int numChoiceVotes;

  const PollChoiceView(
      {Key? key,
      required this.voted,
      required this.text,
      required this.onVote,
      required this.votePercentage,
      required this.index,
      required this.numChoiceVotes})
      : super(key: key);

  @override
  _PollChoiceViewState createState() => _PollChoiceViewState();
}

class _PollChoiceViewState extends State<PollChoiceView> {
  Offset offset = Offset.zero;

  @override
  void initState() {
    setState(() => offset += const Offset(100, 0));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final hp = Provider.of<HeightPixel>(context).value;
    final wp = Provider.of<WidthPixel>(context).value;
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        if (widget.voted == null) {
          widget.onVote();
        }
      },
      child: Container(
          margin: EdgeInsets.all(5 * hp),
          decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10*hp),
            side: BorderSide(
              color: colorScheme.onError,
              width: 1 * hp,
            ),
          )),
          child: Stack(children: <Widget>[
            (widget.voted != null)
                ? LinearPercentIndicator(
                    padding: EdgeInsets.all(0),
                    backgroundColor: colorScheme.surface,
                    animation: true,
                    lineHeight: 32*hp,
                    animationDuration: 700,
                    percent: widget.votePercentage,
                    barRadius: Radius.circular(10*hp),
                    progressColor: colorScheme.primary.withOpacity(0.4),
                  )
                : Container(height: 32*hp),
            AnimatedPositioned(
                child: Text(widget.text, style: Theme.of(context).textTheme.bodyText2),
                top: 7*hp,
                left: widget.voted != null ? 86*wp : 10*wp,
                duration: Duration(milliseconds: 400),
                curve: Curves.linear),
            AnimatedOpacity(
              opacity: widget.voted != null ? 1 : 0,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeIn,
              child: Container(
                  padding: EdgeInsets.only(top: 7*hp),
                  width: 75*wp,
                  child: Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
                    Text(widget.numChoiceVotes.toString() + '   |', style: Theme.of(context).textTheme.bodyText2)
                  ])),
            ),
            AnimatedOpacity(
              opacity: widget.voted == widget.index ? 1 : 0,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeIn,
              child: Container(
                  padding: EdgeInsets.fromLTRB(0, 4*hp, 8*wp, 0),
                  alignment: Alignment.centerRight,
                  width: double.infinity,
                  child: Icon(Icons.check_circle_outline_sharp, size: 23*hp, color: colorScheme.primaryVariant)),
            )
          ])),
    );
  }
}
