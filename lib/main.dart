import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:news_app/news_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_scraper/web_scraper.dart';

void main() => runApp(WebScraperApp());

class WebScraperApp extends StatefulWidget {
  @override
  _WebScraperAppState createState() => _WebScraperAppState();
}

class _WebScraperAppState extends State<WebScraperApp> {
  final webScraper = WebScraper('https://www.thehindu.com');

  final isLoading = ValueNotifier<bool>(false);

  List<NewsModel> news = [];

  void fetchNews() async {
    isLoading.value = true;
    if (await webScraper.loadWebPage('/latest-news/')) {
      setState(
        () {
          List titles = webScraper
              .getElement('ul > li div.right-content h3 a', ['href'])
              .map((e) => e['attributes']['href'])
              .map<String>((e) => e.split('/')[e.split('/').length - 2])
              .toList();

          // List images = webScraper.getElement(
          //   'ul > li div  a  div  img',
          //   ['src']
          // );

          List categories = webScraper
              .getElement('ul > li div.right-content div.label a', []);

          List times = webScraper.getElement(
              'ul > li div.right-content div.news-time.time',
              ['data-published']);

          news = List.generate(
            titles.length,
            (index) => NewsModel(
              title: titles[index],
              time: times[index]['attributes']['data-published'],
              categories: categories[index]['title'],
              // pic: images[index]['src'],
            ),
          );
        },
      );
    }
    isLoading.value = false;
  }

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('NEWS APP'),
        ),
        body: ValueListenableBuilder(
          valueListenable: isLoading,
          builder: (context, value, child) {
            if (value) {
              return Center(child: CircularProgressIndicator());
            }
            return ListView.builder(
              itemCount: news.length,
              itemBuilder: (context, index) {
                return ListTile(
                  // leading: Image.network(news[index].pic ?? ''),
                  title: Text(news[index].title ?? ''),
                  subtitle: Column(
                    children: [
                      Text(news[index].categories ?? ''),
                      Text(
                        DateFormat('dd/MM/yyyy').format(
                          DateTime.parse(
                            news[index].time ?? DateTime.now().toString(),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
