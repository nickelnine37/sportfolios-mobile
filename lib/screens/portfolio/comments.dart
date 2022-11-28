import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/utils/authentication/authenication_provider.dart';
import '../../data/objects/portfolios.dart';
import '../../utils/numerical/dates.dart';

class PortfolioComments extends StatefulWidget {
  final Portfolio portfolio;

  PortfolioComments({required this.portfolio});

  @override
  _PortfolioCommentsState createState() => _PortfolioCommentsState();
}

class _PortfolioCommentsState extends State<PortfolioComments> {
  List<Map<String, dynamic>>? comments;
  TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (comments == null) {
      comments = widget.portfolio.comments.values.toList();
      comments!.sort((a, b) => a['time'].compareTo(b['time']));
    }

    return ListView.separated(
      itemCount: comments!.length + 1,
      itemBuilder: (BuildContext context, int index) {

        if (index < comments!.length) {
          return CommentTile(
            user: comments![index]['username'],
            text: comments![index]['comment'],
            time: comments![index]['time'],
          );
        } else {
          return Container(
            // width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              controller: _textController,
              onSubmitted: (String? comment) {},
              maxLines: 6,
              minLines: 1,
              decoration: InputDecoration(
                hintText: 'Add a comment',
                suffixIcon: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () async {
                      Map<String, dynamic> newComment = {
                        'username': AuthService().username,
                        'comment': _textController.text,
                        'time': DateTime.now().millisecondsSinceEpoch / 1000,
                        'uid': AuthService().currentUid,
                      };

                      print(_textController.text);

                      String commentId = Uuid().v1();

                      setState(() {
                        comments!.add(newComment);
                      });

                      await FirebaseFirestore.instance
                          .collection('portfolios')
                          .doc(widget.portfolio.id)
                          .update({'comments.${commentId}': newComment})
                          .then((value) => print("Comment added"))
                          .catchError((error) => print("Failed to add new comment: $error"));

                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(AuthService().currentUid)
                          .update({'comments.${commentId}': widget.portfolio.id})
                          .then((value) => print("Comment added to user doc"))
                          .catchError((error) => print("Failed to add new comment to user doc: $error"));

                      _textController.clear();
                    }
                    // setState(() {});
                    // }/,
                    ),
              ),
            ),
          );
        }
      },
      separatorBuilder: (BuildContext context, int index) => Divider(
        thickness: 2,
        height: 2,
      ),
    );
  }
}

class CommentTile extends StatelessWidget {
  final String user;
  final String text;
  final double time;

  CommentTile({
    required String this.user,
    required String this.text,
    required double this.time,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(user),
            Text(
              timeAgoSinceDate(time),
              style: TextStyle(fontSize: 14, color: Colors.blue),
            )
          ],
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Text(text),
      ),
    );
  }
}
