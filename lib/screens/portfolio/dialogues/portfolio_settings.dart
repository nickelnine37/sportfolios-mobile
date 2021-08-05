// pop 'updated' if the portfolio was updated
// pop null if nothing changed
// pop 'deleted' if the portfolio was deleted
import 'package:flutter/material.dart';
import 'package:sportfolios_alpha/data/firebase/portfolios.dart';
import 'package:sportfolios_alpha/data/objects/portfolios.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as fire;
import 'package:sportfolios_alpha/utils/authentication/authenication_provider.dart';
import 'package:sportfolios_alpha/utils/strings/string_utils.dart';


class PortfolioSettingsDialogue extends StatefulWidget {
  final Portfolio? portfolio;

  PortfolioSettingsDialogue(this.portfolio);

  @override
  _PortfolioSettingsDialogueState createState() => _PortfolioSettingsDialogueState();
}

class _PortfolioSettingsDialogueState extends State<PortfolioSettingsDialogue> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late Map<String, dynamic> init_values;
  late Map<String, dynamic> output;
  bool loading = false;
  bool deleting = false;

  @override
  void initState() {
    init_values = {'name': widget.portfolio!.name, 'public': widget.portfolio!.public, 'description': widget.portfolio!.description};
    output = {'name': widget.portfolio!.name, 'public': widget.portfolio!.public, 'description': widget.portfolio!.description};
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        height: 500,
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
                  child: Text('Portfolio Setings', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600))),
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
                            width: 150,
                            height: 40,
                            child: TextFormField(
                              initialValue: widget.portfolio!.name,
                              decoration: InputDecoration(hintText: 'MyPortfolio'),
                              onChanged: (String value) {
                                output['name'] = value;
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
                        child: Text('Description', style: TextStyle(fontSize: 16)),
                        alignment: Alignment.centerLeft,
                      ),
                      SizedBox(height: 10),
                      Container(
                        // width: 100,
                        height: 120,
                        child: TextFormField(
                          initialValue: widget.portfolio!.description,
                          maxLines: null,
                          minLines: 6,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(hintText: 'A really wild portfolio...'),
                          onChanged: (String value) {
                            output['description'] = value;
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
                            value: output['public'],
                            onChanged: (value) {
                              setState(() {
                                output['public'] = value;
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  'Public portfolios will be entered into the leaderboard and will be viewable by other users.',
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  // alignment: Alignment.bottomRight,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () async {
                        bool? delete = await showDialog(
                            context: context,
                            builder: (context) {
                              return DeletePortfolioDiaglogue(widget.portfolio!.name);
                            });

                        // if we want to delete
                        if (delete ?? false) {
                          // set the delete wheel spinning
                          setState(() {
                            deleting = true;
                          });
                          // delete the portfolio and wait some more
                          await deletePortfolio(widget.portfolio!.id);
                          await Future.delayed(Duration(seconds: 2));

                          // stop the wheel spinning
                          setState(() {
                            deleting = false;
                          });

                          // pause
                          await Future.delayed(Duration(milliseconds: 800));

                          // pop 'deleted'
                          Navigator.of(context).pop('deleted');
                        }
                      },
                      child: deleting
                          ? Container(
                              height: 25,
                              width: 25,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ))
                          : Text(
                              'Delete',
                              style: TextStyle(color: Colors.white),
                            ),
                      style: ButtonStyle(
                        overlayColor: MaterialStateProperty.all<Color>(Colors.red[400]!),
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.red[400]!),
                        // shape: MaterialStateProperty.all<OutlinedBorder>(
                        //   RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                        // ),
                      ),
                    ),
                    TextButton(
                      style: ButtonStyle(
                        overlayColor: MaterialStateProperty.all<Color>(Colors.blue[400]!),
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.blue[400]!),
                        // shape: MaterialStateProperty.all<OutlinedBorder>(
                        //   RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                        // ),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();

                          if (!FocusScope.of(context).hasPrimaryFocus) {
                            FocusManager.instance.primaryFocus!.unfocus();
                          }

                          if ((output['name'] == init_values['name']) &&
                              (output['public'] == init_values['public']) &&
                              (output['description'] == init_values['description'])) {
                            // pop bool indicating whether changes were made
                            Navigator.of(context).pop(null);
                          } else {
                            setState(() {
                              loading = true;
                            });
                            await Future.delayed(Duration(seconds: 1));
                            output['search_terms'] = getAllSearchTerms(<String>[output['name'], AuthService().username]);
                            await fire.FirebaseFirestore.instance
                                .collection('portfolios')
                                .doc(widget.portfolio!.id)
                                .update(output)
                                .then((value) => print("User Updated"))
                                .catchError((error) => print("Failed to update user portfolio: $error"));

                            widget.portfolio!.name = output['name'];
                            widget.portfolio!.public = output['public'];
                            widget.portfolio!.description = output['description'];
                            // pop bool indicating whether changes were made
                            Navigator.of(context).pop('updated');
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
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// pop true to delete the portfolio
// pop false or null to keep it
class DeletePortfolioDiaglogue extends StatelessWidget {
  final String portfolioName;

  DeletePortfolioDiaglogue(this.portfolioName);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        height: 200,
        padding: EdgeInsets.only(top: 16, left: 16, right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10.0, offset: const Offset(0.0, 10.0))],
        ),
        child: Column(
          children: [
            Container(
                padding: EdgeInsets.all(16),
                child: Text('Delete Portfolio', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600))),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'Are you sure you want to delete the portfolio ${portfolioName}? This is irreversible',
                textAlign: TextAlign.center,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text(
                    'Delete',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text('Cancel', style: TextStyle(fontSize: 20)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
