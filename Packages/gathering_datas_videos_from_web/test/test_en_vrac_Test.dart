import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gathering_datas_videos_from_web/gathering_datas_videos_from_web.dart';
import 'package:html/dom.dart';
import 'package:intl/intl.dart';
import 'package:xpath_selector/xpath_selector.dart';
import 'package:xpath_selector_html_parser/xpath_selector_html_parser.dart';

import 'package:path/path.dart' as p;

void main() {
  late String htmlDoc;
  setUpAll(() {
    htmlDoc = """
             <div class="summary_content_wrap">
    <div class="summary_content">
        <div class="post-content">
            <div class="loader-inner ball-pulse">
    <div></div>
    <div></div>
    <div></div>
</div>            
            <div class="post-rating">
	<div class="post-total-rating allow_vote"><i class="ion-ios-star ratings_stars rating_current"></i><i class="ion-ios-star ratings_stars rating_current"></i><i class="ion-ios-star ratings_stars rating_current"></i><i class="ion-ios-star ratings_stars rating_current"></i><i class="ion-ios-star ratings_stars rating_current"></i><span class="score font-meta total_votes">4.9</span></div><div class="user-rating allow_vote"><i class="ion-ios-star-outline ratings_stars"></i><i class="ion-ios-star-outline ratings_stars"></i><i class="ion-ios-star-outline ratings_stars"></i><i class="ion-ios-star-outline ratings_stars"></i><i class="ion-ios-star-outline ratings_stars"></i><span class="score font-meta total_votes">Your Rating</span></div><input type="hidden" class="rating-post-id" value="105653"></div>

			<div class="post-content_item">
			<div class="summary-heading">
				<h5>
					Native				</h5>
			</div>
			<div class="summary-content">
				WIND BREAKER Season 2			</div>
		</div>
	

			<div class="post-content_item">
			<div class="summary-heading">
				<h5>
					Romaji				</h5>
			</div>
			<div class="summary-content">
				WIND BREAKER Season 2			</div>
		</div>
	

			<div class="post-content_item">
			<div class="summary-heading">
				<h5>
					English				</h5>
			</div>
			<div class="summary-content">
				WIND BREAKER Season 2			</div>
		</div>
	

	
<div class="post-content_item">
	<div class="summary-heading">
		<h5>Note</h5>
	</div>
	<div class="summary-content vote-details" xmlns:v="http://rdf.data-vocabulary.org/#" typeof="v:Review-aggregate">
		<span property="v:itemreviewed"><span class="rate-title" title="Wind Breaker 2">Wind Breaker 2</span></span><span> <span> Average <span id="averagerate"> 4.9</span> / <span>5</span> </span> out of <span id="countrate">2K</span></span>	</div>
</div><div class="post-content_item">
	<div class="summary-heading">
		<h5>
			Type		</h5>
	</div>
	<div class="summary-content">
		TV	</div>
</div>
<div class="post-content_item">
	<div class="summary-heading">
		<h5>
			Status		</h5>
	</div>
	<div class="summary-content">
		EN COURS	</div>
</div>

	
			<div class="post-content_item">
			<div class="summary-heading">
				<h5>
					Studios				</h5>
			</div>
			<div class="summary-content">
				CloverWorks			</div>
		</div>
	

	
	

	
			<div class="post-content_item">
			<div class="summary-heading">
				<h5>
					Start date				</h5>
			</div>
			<div class="summary-content">
				Apr 3, 2025			</div>
		</div>
	

	
	


<div class="post-content_item">
	<div class="summary-heading">
		<h5>
			Genre(s)		</h5>
	</div>
	<div class="summary-content">
		<div class="genres-content">
			<a href="https://v6.voiranime.com/anime-genre/action/" rel="tag">Action</a>, <a href="https://v6.voiranime.com/anime-genre/comedy/" rel="tag">Comedy</a>, <a href="https://v6.voiranime.com/anime-genre/drama/" rel="tag">Drama</a>		</div>
	</div>
</div>



	
	
            
                        
        </div>
        <div class="post-status">
        
            <div class="manga-action">
			</div>
        </div>
        
        
<div id="init-links" class="nav-links">
				<a href="#" id="btn-read-last" class="c-btn c-btn_style-1">
			Premier EP</a>
			<a href="#" id="btn-read-first" class="c-btn c-btn_style-1">Dernier EP</a>
			</div>

    </div>
</div>
          """;
  });
  group("vrac", () {
    test("test 1", () async {
      //ARRANGE
      //ACT
      var dom = ManagerHtmlDom.ParseHtmlDoc(htmlDoc);
      var el = dom.queryXPath(
          "//div[@class='post-content_item']/div/h5[contains(text(),'Start date')]/ancestor::*/ancestor::*/div[@class='summary-content']");
      //ASSERT
      late DateTime date;
      if (el.nodes.isNotEmpty) {
        date = DateFormat("MMM dd, yyyy").parse(el.nodes.first.text!.trim());
      }
      var st = date.toIso8601String();

      expect(date, isNotNull);
    });
  });
}
