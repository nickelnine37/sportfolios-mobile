import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

import '../../../data/objects/markets.dart';
import '../market_scroll.dart';
import '../../../utils/design/colors.dart';

class TeamPlayers extends StatefulWidget {
  final Market? team;

  TeamPlayers(this.team);

  @override
  _TeamPlayersState createState() => _TeamPlayersState();
}

class _TeamPlayersState extends State<TeamPlayers> {
  Future<void>? getPlayerInfoFuture;

  @override
  void initState() {
    super.initState();
  }

  Future<void> getPlayerInfo() async {}

  @override
  Widget build(BuildContext context) {
    Color background = fromHex(widget.team!.colours![0]);
    Color? textColor = background.computeLuminance() > 0.5 ? Colors.grey[700] : Colors.white;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
            decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [background, Colors.white],
              begin: const FractionalOffset(0.4, 0.5),
              end: const FractionalOffset(1, 0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp),
        )),
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        toolbarHeight: 72,
        title: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                color: textColor,
                icon: Icon(
                  Icons.arrow_back,
                  size: 22,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              Container(
                height: 50,
                child: Platform.isAndroid
                    ? CachedNetworkImage(
                        imageUrl: widget.team!.imageURL!,
                      )
                    : Image(image: AssetImage('assets/kits/${widget.team!.rawId}_cropped.png')),
              ),
              SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.team!.name!, style: TextStyle(fontSize: 23.0, color: textColor)),
                  SizedBox(height: 2),
                  Text(
                    'Players',
                    style: TextStyle(fontSize: 15.0, color: textColor), // fontWeight: FontWeight.w400),
                  )
                ],
              ),
            ],
          ),
        ]),
      ),
      body: MarketScroll(teamId: int.parse(widget.team!.id.split(':')[0])),
    );
  }
}
