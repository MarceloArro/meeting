/*import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:meeting/utils/string_utils.dart';

//a Class that create a new link with the group sharedLink  to join an a group
class DynamicLinkFirebase {

  //generate the link
  Future<Uri> generateLink(String groupLink) async {
    //Url for the application if does not installed
    final String fallBackUrl =
        "https://meeting-test-api.herokuapp.com/api/v1/docs";

    //Params to generate the Dynamic Link
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      //General url params
      uriPrefix: 'https://ceismeeting.page.link/',
      link: Uri.parse(
          'https://meeting-test-api.herokuapp.com/api/v1/add-member=$groupLink/'),

      //Dynamic short link options
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      ),

      //MetaTag Params
      socialMetaTagParameters: SocialMetaTagParameters(
        title: AppStrings.joinToMiGroup,
        description: AppStrings.joinGroupDescription,
      ),

      //android parameters
      androidParameters: AndroidParameters(
        packageName: 'cl.ufro.ceis.meeting',
        fallbackUrl: Uri.parse(fallBackUrl),
      ),

      //ios parameters
      iosParameters: IosParameters(
        bundleId: 'BUNDLE OF IOS',
        fallbackUrl: Uri.parse(fallBackUrl),
      ),
    );

    //Use the parameters of the Dynamic link and create a shorted link
    final ShortDynamicLink shortLink = await parameters.buildShortLink();

    //Return the Url shortLink;
    return shortLink.shortUrl;
  }
}*/
