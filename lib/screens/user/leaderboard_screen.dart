import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trash_scout/shared/theme/theme.dart';
import 'package:trash_scout/shared/utils/capitalize.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<Map<String, dynamic>> users = [];
  bool _isLoading = true;
  Map<String, dynamic>? currentUser;
  int currentUserRank = 0;

  @override
  void initState() {
    super.initState();
    _getUsersWithReportCount();
  }

  Future<void> _getUsersWithReportCount() async {
    try {
      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'user')
          .get();

      List<Map<String, dynamic>> usersData = [];

      for (var userDoc in usersSnapshot.docs) {
        QuerySnapshot reportsSnapshot =
            await userDoc.reference.collection('reports').get();
        int reportCount = reportsSnapshot.size;

        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        userData['id'] = userDoc.id;
        userData['reportCount'] = reportCount;
        userData['profileImageUrl'] = userData['profileImageUrl'] ??
            'https://firebasestorage.googleapis.com/v0/b/trash-scout-3c117.appspot.com/o/users%2Fdefault_profile_image%2Fuser%20default%20profile.png?alt=media&token=79ef1308-3d3d-477d-b566-0c4e66848a4d'; // Berikan URL default jika null
        usersData.add(userData);
      }

      // Sorting users by reportCount in descending order
      usersData.sort((a, b) => b['reportCount'].compareTo(a['reportCount']));

      // Get current user's rank
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        currentUser =
            usersData.firstWhere((u) => u['id'] == user.uid, orElse: () => {});
        currentUserRank = usersData.indexOf(currentUser!) + 1;
      }

      if (mounted) {
        setState(() {
          users = usersData;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching users: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: darkGreenColor,
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 271,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage('assets/leaderboard_bg.png'),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 50),
                        Text(
                          'Leaderboard',
                          style: boldTextStyle.copyWith(
                            color: whiteColor,
                            fontSize: 26,
                          ),
                        ),
                        SizedBox(height: 20),
                        if (currentUser != null)
                          UserCurrentRank(
                            user: currentUser!,
                            rank: currentUserRank,
                          ),
                        SizedBox(height: 12),
                        Text(
                          'Menangkan Hadiah dengan mencapai peringkat pertama!',
                          style: semiBoldTextStyle.copyWith(
                            color: whiteColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 11),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Top 5 Scouters: ',
                      style: mediumTextStyle.copyWith(
                        color: blackColor,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(height: 11),
                  ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: users.length < 5 ? users.length : 5,
                    itemBuilder: (context, index) {
                      return LeaderboardItem(
                        user: users[index],
                        rank: index + 1,
                      );
                    },
                  ),
                  // if (currentUserRank > 5)
                  //   LeaderboardItem(
                  //     user: currentUser!,
                  //     rank: currentUserRank,
                  //   ),
                ],
              ),
            ),
    );
  }
}

class LeaderboardItem extends StatelessWidget {
  final Map<String, dynamic> user;
  final int rank;
  const LeaderboardItem({required this.user, required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 13.5,
        vertical: 17,
      ),
      margin: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 10,
      ),
      width: double.infinity,
      height: 80,
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: blackColor.withOpacity(0.1),
            offset: Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            '$rank',
            style: boldTextStyle.copyWith(
              color: Color(0xffE4C041),
              fontSize: 20,
            ),
          ),
          SizedBox(width: 9),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(
                  (user.containsKey('profileImageUrl') &&
                          user['profileImageUrl'] != null &&
                          user['profileImageUrl'].toString().isNotEmpty)
                      ? user['profileImageUrl']
                      : 'https://firebasestorage.googleapis.com/v0/b/trash-scout-3c117.appspot.com/o/users%2Fdefault_profile_image%2Fuser%20default%20profile.png?alt=media&token=79ef1308-3d3d-477d-b566-0c4e66848a4d',
                ),
              ),
            ),
          ),
          SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user['name'],
                style: mediumTextStyle.copyWith(
                  color: blackColor,
                  fontSize: 15,
                ),
              ),
              Text(
                capitalize(user['regency']),
                style: regularTextStyle.copyWith(
                  color: darkGreyColor,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          Expanded(child: Container()),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${user['reportCount']}',
                style: boldTextStyle.copyWith(
                  fontSize: 18,
                  color: blackColor,
                ),
              ),
              Text(
                'laporan',
                style: mediumTextStyle.copyWith(
                  fontSize: 12,
                  color: darkGreyColor,
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class UserCurrentRank extends StatelessWidget {
  final Map<String, dynamic> user;
  final int rank;
  const UserCurrentRank({required this.user, required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 110,
      padding: EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: blackColor.withOpacity(0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(
                  (user.containsKey('profileImageUrl') &&
                          user['profileImageUrl'] != null &&
                          user['profileImageUrl'].toString().isNotEmpty)
                      ? user['profileImageUrl']
                      : 'https://firebasestorage.googleapis.com/v0/b/trash-scout-3c117.appspot.com/o/users%2Fdefault_profile_image%2Fuser%20default%20profile.png?alt=media&token=79ef1308-3d3d-477d-b566-0c4e66848a4d',
                ),
              ),
            ),
          ),
          SizedBox(width: 9),
          Text(
            'Posisi anda\nSekarang',
            style: mediumTextStyle.copyWith(
              color: whiteColor,
              fontSize: 15,
            ),
          ),
          Expanded(child: Container()),
          Text(
            '$rank',
            style: boldTextStyle.copyWith(
              color: whiteColor,
              fontSize: 50,
            ),
          ),
          VerticalDivider(
            color: whiteColor,
            indent: 30,
            endIndent: 24,
            thickness: 0.3,
            width: 20,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 35,
              ),
              Text(
                '${user['reportCount']}',
                style: boldTextStyle.copyWith(
                  color: whiteColor,
                  fontSize: 16,
                ),
              ),
              Text(
                'laporan',
                style: mediumTextStyle.copyWith(
                  color: whiteColor,
                  fontSize: 12,
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
