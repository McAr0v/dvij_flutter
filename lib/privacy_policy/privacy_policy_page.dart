import 'package:dvij_flutter/dates/date_mixin.dart';
import 'package:dvij_flutter/elements/loading_screen.dart';
import 'package:dvij_flutter/privacy_policy/privacy_policy_class.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {

  PrivacyPolicyClass privacyPolicy = PrivacyPolicyClass.empty();

  String text = '';

  bool loading = false;

  @override
  void initState() {
    _initializeData();
    super.initState();
  }

  Future<void> _initializeData() async {

    setState(() {
      loading = true;
    });

    List <PrivacyPolicyClass> tempList = await privacyPolicy.getPoliciesFromDb();

    setState(() {
      privacyPolicy = (privacyPolicy.getLatestPrivacyPolicy(tempList) ?? PrivacyPolicyClass.empty());
      loading = false;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Политика конфиденциальности'),
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.chevronLeft, size: 18,),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          if (loading) const LoadingScreen(loadingText: 'Идет загрузка',)
          else SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Политика конфиденциальности', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 30), softWrap: true,),
                const SizedBox(height: 5.0),
                Text('от ${DateMixin.getHumanDateFromDateTime(privacyPolicy.date)}', style: Theme.of(context).textTheme.labelMedium,),
                const SizedBox(height: 15.0),
                Text( privacyPolicy.startText,
                  style: Theme.of(context).textTheme.bodyMedium,),
                const SizedBox(height: 25.0),

                Text('1 - Сбор данных', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20), softWrap: true,),
                const SizedBox(height: 10.0),

                Text( privacyPolicy.dataCollection,
                  style: Theme.of(context).textTheme.bodyMedium,),
                const SizedBox(height: 25.0),

                Text('2 - Использование данных', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20), softWrap: true,),
                const SizedBox(height: 10.0),

                Text( privacyPolicy.dataUsage,
                  style: Theme.of(context).textTheme.bodyMedium,),
                const SizedBox(height: 25.0),

                Text('3 - Передача данных третьим лицам', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20), softWrap: true,),
                const SizedBox(height: 10.0),

                Text( privacyPolicy.transferData,
                  style: Theme.of(context).textTheme.bodyMedium,),
                const SizedBox(height: 25.0),

                Text('4 - Безопасность данных', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20), softWrap: true,),
                const SizedBox(height: 10.0),

                Text( privacyPolicy.dataSecurity,
                  style: Theme.of(context).textTheme.bodyMedium,),
                const SizedBox(height: 25.0),

                Text('5 - Ваши права', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20), softWrap: true,),
                const SizedBox(height: 10.0),

                Text( privacyPolicy.yourRights,
                  style: Theme.of(context).textTheme.bodyMedium,),
                const SizedBox(height: 25.0),

                Text('6 - Изменения в Политике конфиденциальности', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20), softWrap: true,),
                const SizedBox(height: 10.0),

                Text( privacyPolicy.changes,
                  style: Theme.of(context).textTheme.bodyMedium,),
                const SizedBox(height: 25.0),

                Text('7 - Контактная информация', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 20), softWrap: true,),
                const SizedBox(height: 10.0),

                Text( privacyPolicy.contacts,
                  style: Theme.of(context).textTheme.bodyMedium,),

              ],

            ),
          )
        ],
      ),
    );
  }
}
