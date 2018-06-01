import 'package:coordn8r/login_page.dart';
import 'package:coordn8r/pages/teams_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:community_material_icon/community_material_icon.dart';

class HomePage extends StatelessWidget {
  static String tag = 'home_page';

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () {
        return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Are you sure?'),
              content: Text('Going back will log you out.'),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.of(context).pushNamed(
                      LoginPage.tag), // also Navigator.of(context).pop(true)
                  child: Text('Yes'),
                ),
                FlatButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('No'),
                )
              ],
            );
          },
        );
      },
      child: new DefaultTabController(
        length: 4,
        child: new Scaffold(
//          appBar: new AppBar(
//            title: new Text('Coordn8r'),
//          ),
          body: new SafeArea(
            child: new TabBarView(
              children: [
                new TeamsPage(),
                new Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).primaryColor,
                ),
                new Icon(
                  Icons.fiber_new,
                  color: Theme.of(context).primaryColor,
                ),
                new Icon(
                  Icons.account_box,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
          bottomNavigationBar: new TabBar(
            tabs: [
              new Tab(
                  icon: new Icon(
                CommunityMaterialIcons.group,
                color: Colors.orange,
              )),
              new Tab(
                  icon: new Icon(
                Icons.calendar_today,
                color: Theme.of(context).primaryColor,
              )),
              new Tab(
                  icon: new Icon(
                Icons.fiber_new,
                color: Theme.of(context).primaryColor,
              )),
              new Tab(
                  icon: new Icon(
                Icons.account_box,
                color: Theme.of(context).primaryColor,
              )),
            ],
          ),
        ),
      ),
    );
  }
}
