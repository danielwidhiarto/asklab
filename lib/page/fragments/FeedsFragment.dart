import 'package:asklab/page/DetailPost.dart';
import 'package:asklab/page/model/Feed.dart';
import 'package:flutter/material.dart';
import '../NotificationPage.dart'; // Import the NotificationPage

class FeedsFragment extends StatefulWidget {
  const FeedsFragment({Key? key}) : super(key: key);

  @override
  State<FeedsFragment> createState() => _FeedsFragmentState();
}

class _FeedsFragmentState extends State<FeedsFragment> {

  List<Feed> feedsList = [];

  @override
  void initState() {
    super.initState();
    fetchFeeds();
  }

  void fetchFeeds() async {
    FeedApi feedApi = FeedApi();
    List <Feed> feeds = await feedApi.fetchFeeds();

    setState(() {
      feedsList = feeds;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
        backgroundColor: const Color(0xFF009ADB),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Navigate to NotificationPage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: feedsList.length, // Replace with your dynamic post count
        itemBuilder: (context, index) {

          final feed = feedsList[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundImage: AssetImage(
                              'assets/images/avatar_placeholder.png'), // Replace with user avatar
                          radius: 20,
                        ),
                        const SizedBox(width: 12.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              feed.title, // Replace with post title
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                            Text(
                              "${feed.username}", // Replace with author name
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14.0,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            // Implement detail functionality
                            Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPost(
                              postId: feed.feedId, 
                              title: feed.title, 
                              images: feed.images, 
                              description: feed.description, 
                              timestamp: feed.timestamp)));

                              fetchFeeds();
                          },
                          child: Row(
                            children: const [
                              Text(
                                'Detail',
                                style: TextStyle(color: Color(0xFF009ADB)),
                              ),
                              Icon(
                                Icons.arrow_forward,
                                color: Color(0xFF009ADB),
                                size: 16.0,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      "${feed.description}",
                      style: TextStyle(fontSize: 14.0, color: Colors.black87),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: feed.images.isNotEmpty ? Image.network(
                              feed.images.first, // Replace with post image
                              height: 100,
                              fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            (loadingProgress.expectedTotalBytes ?? 1)
                                        : null,
                                  ),
                                );
                              },
                            ) : Image.asset(
                              'assets/images/placeholder.png',
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Container(
                          width: 50,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color: Colors.grey[200],
                          ),
                          child: Center(
                            child: Text(
                              '+4', // Replace with additional image count
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    const Text(
                      '1 hour ago', // Replace with timestamp
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
