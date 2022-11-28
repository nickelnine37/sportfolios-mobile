// pop String new Pid if success, null otherwise
import 'package:flutter/material.dart';
import '../../../data/api/requests.dart';
import 'package:english_words/english_words.dart';

class NewPortfolioDialogue extends StatefulWidget {
  @override
  _NewPortfolioDialogueState createState() => _NewPortfolioDialogueState();
}

class _NewPortfolioDialogueState extends State<NewPortfolioDialogue> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool public = true;
  String name = '';
  bool loading = false;
  bool error = false;
  String _description = '';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        height: error ? 520 : 470,
        padding: EdgeInsets.only(top: 16, left: 16, right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10.0, offset: const Offset(0.0, 10.0))],
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text('New portfolio', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600))),
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Name', style: TextStyle(fontSize: 16)),
                          Container(
                            width: 100,
                            height: 40,
                            child: TextFormField(
                              decoration: InputDecoration(hintText: WordPair.random().asCamelCase),
                              onChanged: (String value) {
                                name = value;
                              },
                              validator: (String? value) {
                                if (value == '' || value == null) {
                                  return 'Please enter valid portfolio name';
                                } else if (value.length > 20) {
                                  return 'Portfolio names must be 20 characters or less';
                                } else {
                                  return null;
                                }
                              },
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 30),
                      Align(
                        child: Text('Description (optional)', style: TextStyle(fontSize: 16)),
                        alignment: Alignment.centerLeft,
                      ),
                      SizedBox(height: 10),
                      Container(
                        // width: 100,
                        height: 120,
                        child: TextFormField(
                          maxLines: null,
                          minLines: 6,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(hintText: 'A really wild portfolio...'),
                          onChanged: (String value) {
                            _description = value;
                          },
                          validator: (String? value) {
                            if (value == null) {
                              return null;
                            }
                            if (value.length > 2000) {
                              return 'Description too long';
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Public', style: TextStyle(fontSize: 16)),
                          Switch(
                            value: public,
                            onChanged: (value) {
                              setState(() {
                                public = value;
                              });
                            },
                            activeTrackColor: Colors.lightBlueAccent,
                            activeColor: Colors.blue,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                'Public portfolios will be entered into the leaderboard and will be viewable by other users.',
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15),
              error
                  ? Text(
                      'There was an error creating a new portfolio. Please try again later',
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    )
                  : Container(),
              error ? SizedBox(height: 15) : Container(),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all<Color>(Colors.blue[400]!),
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blue[400]!),
                    // shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))),
                  ),
                  onPressed: error
                      ? () {
                          Navigator.of(context).pop(null);
                        }
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            if (!FocusScope.of(context).hasPrimaryFocus) {
                              FocusManager.instance.primaryFocus!.unfocus();
                            }

                            setState(() {
                              loading = true;
                            });

                            String? newPid = await createNewPortfolio(name, public, _description);
                            // String? newPid = null;
                            // await Future.delayed(Duration(seconds: 2));

                            await Future.delayed(Duration(seconds: 1));

                            if (newPid == null) {
                              setState(() {
                                error = true;
                                loading = false;
                              });
                            } else {
                              // pop true to indicate portfolio has been added
                              Navigator.of(context).pop(newPid);
                            }
                          }
                        },
                  child: loading
                      ? Container(
                          height: 25,
                          width: 25,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ))
                      : Text(
                          'OK',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

