import 'package:dvij_flutter/current_user/user_class.dart';
import 'package:dvij_flutter/database/database_mixin.dart';
import 'package:dvij_flutter/elements/buttons/custom_button.dart';
import 'package:dvij_flutter/elements/loading_screen.dart';
import 'package:dvij_flutter/feedback_messages/feedback_enums.dart';
import 'package:dvij_flutter/feedback_messages/feedback_messages_class.dart';
import 'package:dvij_flutter/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../elements/snack_bar.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({Key? key}) : super(key: key);

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {

  final TextEditingController messageController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  FeedbackTopicEnum _selectedTopic = FeedbackTopicEnum.other;

  bool saving = false;

  FeedbackMessages feedbackMessage = FeedbackMessages.empty();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Написать разработчику'),
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.chevronLeft, size: 18,),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          if (saving) const LoadingScreen(loadingText: 'Идет сохранение',)
          else SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Написать разработчику', style: Theme.of(context).textTheme.titleLarge,),
                const SizedBox(height: 15.0),
                Text('Мы всегда рады услышать твои мысли! '
                    '🙌 На этой странице ты можешь поделиться с нами своим мнением о приложении. '
                    'Наши двери открыты для сообщений о найденных багах, предложениях по улучшению и любых других идеях. '
                    'Вместе мы сделаем наше приложение еще лучше! 💡✉️',
                  style: Theme.of(context).textTheme.bodyMedium,),
                const SizedBox(height: 25.0),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.greyOnBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Тема сообщения', style: Theme.of(context).textTheme.titleMedium,),

                      const SizedBox(height: 10.0),

                      DropdownButton<FeedbackTopicEnum>(
                        style: Theme.of(context).textTheme.bodySmall,
                        isExpanded: true,
                        value: _selectedTopic,
                        onChanged: (FeedbackTopicEnum? newValue) {
                          setState(() {
                            _selectedTopic = newValue!;
                          });
                        },
                        items: feedbackMessage.getDropdownItems(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25.0),

                TextField(
                  style: Theme.of(context).textTheme.bodyMedium,
                  keyboardType: TextInputType.multiline,
                  controller: messageController,
                  decoration: const InputDecoration(
                    labelText: 'Напиши сообщение...',
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                  onEditingComplete: () {
                    // Обработка события, когда пользователь нажимает Enter
                    // Вы можете добавить здесь любой код, который нужно выполнить при нажатии Enter
                  },
                ),

                const SizedBox(height: 25.0),

                TextField(
                  style: Theme.of(context).textTheme.bodyMedium,
                  keyboardType: TextInputType.phone,
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Телефон для связи',
                  ),
                ),

                const SizedBox(height: 25.0),

                CustomButton(
                    buttonText: 'Отправить сообщение',
                    onTapMethod: () async {
                      await publishMessage();
                    }
                ),

              ],

            ),
          )
        ],
      ),
    );
  }

  Future<void> publishMessage() async {

    if (messageController.text.toString().isNotEmpty){
      setState(() {
        saving = true;
      });

      String messageId = MixinDatabase.generateKey()!;
      String userId = UserCustom.currentUser != null ? UserCustom.currentUser!.uid : '';

      feedbackMessage.topic = _selectedTopic;
      feedbackMessage.status = FeedbackStatusEnum.received;
      feedbackMessage.id = messageId;
      feedbackMessage.phone = phoneController.text.toString();
      feedbackMessage.userId = userId;
      feedbackMessage.messageText = messageController.text.toString();
      feedbackMessage.messageDate = DateTime.now();

      String publishResult = await feedbackMessage.publishToDb();

      setState(() {
        saving = false;
      });

      if (publishResult == 'success'){
        _showSnackBar('Сообщение успешно отправлено! Мы примем ваши пожелания к сведению!', Colors.green, 2);
        _navigateToEventsAfterPublish();
      } else {
        _showSnackBar('Сообщение не отправлено по ошибке: $publishResult', AppColors.attentionRed, 2);
      }


    } else {
      _showSnackBar('Введи текст сообщения!', AppColors.attentionRed, 2);
    }



  }

  void _showSnackBar(String text, Color color, int time){
    showSnackBar(context, text, color, time);
  }

  void _navigateToEventsAfterPublish() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/Events',
          (route) => false,
    );
  }

}
