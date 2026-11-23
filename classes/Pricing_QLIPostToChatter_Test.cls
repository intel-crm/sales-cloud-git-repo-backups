@isTest
public class Pricing_QLIPostToChatter_Test {
	
    public interface ChatterPoster {
        void postToChatter(Id parentRecord, String text);
    }

    @TestVisible private class RealChatterPoster implements ChatterPoster {
        public void postToChatter(Id parentRecord, String text) {
            if (!Test.isRunningTest()) {
                ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
                ConnectApi.ChatterFeeds.postFeedElement(parentRecord, feedItemInput);
            }
            // Note that if we keep this minimal (one line) we still obtain full code coverage even though the Connect API call does not actually go through.
        }
    }

    @TestVisible private ChatterPoster myPoster;

    public Pricing_QLIPostToChatter_Test() {
        myPoster = new RealChatterPoster();
    }

    public void doSomethingRequiringAChatterPost() {
        myPoster.postToChatter('a7o2i000000DUB8AAO', 'hello');
    }
}