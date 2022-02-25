import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hs_connect/models/poll.dart';
import 'package:hs_connect/models/post.dart';
import 'package:hs_connect/services/polls_database.dart';
import 'package:hs_connect/shared/inputDecorations.dart';

import 'package:percent_indicator/linear_percent_indicator.dart';

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

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
            side: BorderSide(
              color: colorScheme.onError,
              width: 1,
            ),
          )
        ),
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.only(top: 10),
        child: ListView.builder(
          itemCount: widget.poll.choices.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemBuilder: (BuildContext context, int index) {
            return PollChoiceView(
                voted: voted,
                text: widget.poll.choices[index],
                totalVotes: totalVotes,
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

class PollChoiceView extends StatelessWidget {
  final int? voted;
  final String text;
  final int totalVotes;
  final VoidFunction onVote;
  final int index;
  final int numChoiceVotes;

  const PollChoiceView(
      {Key? key,
      required this.voted,
      required this.text,
      required this.onVote,
      required this.totalVotes,
      required this.index,
      required this.numChoiceVotes})
      : super(key: key);

  @override
  Widget build(BuildContext context) {


    final colorScheme = Theme.of(context).colorScheme;

    String votePercentage = totalVotes != 0 ? (100*numChoiceVotes/totalVotes).round().toString()+'%' : '0%';
    return GestureDetector(
      onTap: () {
        if (voted == null) {
          onVote();
        }
      },
      child: Container(
          margin: EdgeInsets.all(5),
          decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: colorScheme.onError,
              width: 1,
            ),
          )),
          child: Stack(children: <Widget>[
            (voted != null)
                ? LinearPercentIndicator(
                    padding: EdgeInsets.zero,
                    backgroundColor: colorScheme.surface,
                    animation: true,
                    lineHeight: 32,
                    animationDuration: 700,
                    percent: totalVotes!=0 ? numChoiceVotes / totalVotes : 0,
                    barRadius: Radius.circular(10),
                    progressColor: colorScheme.primary.withOpacity(0.4),
                  )
                : Container(height: 32),
            AnimatedPositioned(
                child: Text(text, style: Theme.of(context).textTheme.bodyText2),
                top: 7,
                left: voted != null ? 86 : 10,
                duration: Duration(milliseconds: 400),
                curve: Curves.linear),
            AnimatedOpacity(
              opacity: voted != null ? 1 : 0,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeIn,
              child: Container(
                  padding: EdgeInsets.only(top: 7),
                  width: 75,
                  child: Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
                    Text(votePercentage + '   |', style: Theme.of(context).textTheme.bodyText2)
                  ])),
            ),
            AnimatedOpacity(
              opacity: voted == index ? 1 : 0,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeIn,
              child: Container(
                  padding: EdgeInsets.fromLTRB(0, 4, 8, 0),
                  alignment: Alignment.centerRight,
                  width: double.infinity,
                  child: Icon(Icons.check_circle_outline_sharp, size: 23, color: colorScheme.primaryContainer)),
            )
          ])),
    );
  }
}
