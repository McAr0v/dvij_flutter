import 'package:dvij_flutter/feedback_messages/feedback_enums.dart';
import 'package:flutter/material.dart';
import '../database/database_mixin.dart';
import '../dates/date_mixin.dart';
import '../events/event_sorting_options.dart';

class FeedbackMessages {

  DateTime messageDate;
  FeedbackStatusEnum status;
  FeedbackTopicEnum topic;
  String messageText;
  String userId;
  String phone;
  String id;

  FeedbackMessages({
        required this.id,
        required this.messageText,
        required this.status,
        required this.topic,
        required this.messageDate,
        required this.phone,
        required this.userId
      });

  factory FeedbackMessages.empty(){
    return FeedbackMessages(
        id: '',
        messageText: '',
        status: FeedbackStatusEnum.received,
        topic: FeedbackTopicEnum.other,
        messageDate: DateTime.now(),
        phone: '',
        userId: ''
    );
  }

  Future<String> publishToDb() async{
    String messagePath = 'feedback/$id/message_info/';

    Map<String, dynamic> data = generateEntityDataCode();

    String entityPublishResult = await MixinDatabase.publishToDB(messagePath, data);

    return entityPublishResult;

  }

  Map<String, dynamic> generateEntityDataCode() {

    return <String, dynamic> {
      'messageDate': DateMixin.generateDateString(messageDate),
      'status': _getStatusString(statusEnum: status),
      'topic': _getTopicString(topicEnum: topic),
      'messageText': messageText,
      'userId': userId,
      'phone': phone,
      'id': id,
    };
  }



  String _getStatusString({required FeedbackStatusEnum statusEnum, bool needTranslate = false}){
    switch (statusEnum){
      case FeedbackStatusEnum.inProgress: return !needTranslate ? 'inProgress' : 'Сообщение обрабатывается';
      case FeedbackStatusEnum.received: return !needTranslate ? 'received' : 'Сообщение получено';
      case FeedbackStatusEnum.resolved: return !needTranslate ? 'resolved' : 'Проблема решена';
      case FeedbackStatusEnum.dismissed: return !needTranslate ? 'dismissed' : 'Сообщение отклонено';
      case FeedbackStatusEnum.awaitingResponse: return !needTranslate ? 'awaitingResponse' : 'Ожидается ответ от пользователя';
      case FeedbackStatusEnum.escalated: return !needTranslate ? 'escalated' : 'Сообщение передано на более высокий уровень';
      case FeedbackStatusEnum.closed: return !needTranslate ? 'closed' : 'Обработка завершена';
    }
  }

  FeedbackStatusEnum _getStatusFromString({required String statusEnumInString}){
    switch (statusEnumInString){
      case 'received': return FeedbackStatusEnum.received;
      case 'inProgress': return FeedbackStatusEnum.inProgress;
      case 'resolved': return FeedbackStatusEnum.resolved;
      case 'dismissed': return FeedbackStatusEnum.dismissed;
      case 'awaitingResponse': return FeedbackStatusEnum.awaitingResponse;
      case 'escalated': return FeedbackStatusEnum.escalated;
      case 'closed': return FeedbackStatusEnum.closed;
      default: return FeedbackStatusEnum.received;
    }
  }

  String _getTopicString({required FeedbackTopicEnum topicEnum, bool needTranslate = false}){
    switch (topicEnum){
      case FeedbackTopicEnum.bugReport: return !needTranslate ? 'bugReport' : 'Сообщение о баге или ошибке в приложении';
      case FeedbackTopicEnum.featureRequest: return !needTranslate ? 'featureRequest' : 'Запрос на добавление новой функции';
      case FeedbackTopicEnum.uiUx: return !needTranslate ? 'uiUx' : 'Вопросы, связанные с пользовательским интерфейсом и удобством использования';
      case FeedbackTopicEnum.performance: return !needTranslate ? 'performance' : 'Вопросы, связанные с производительностью приложения';
      case FeedbackTopicEnum.accountIssues: return !needTranslate ? 'accountIssues' : 'Проблемы, связанные с учетной записью пользователя';
      case FeedbackTopicEnum.paymentIssues: return !needTranslate ? 'paymentIssues' : 'Проблемы с оплатой или подпиской';
      case FeedbackTopicEnum.generalFeedback: return !needTranslate ? 'generalFeedback' : 'Общие отзывы или предложения';
      case FeedbackTopicEnum.other: return !needTranslate ? 'other' : 'Другое';

    }
  }

  List<DropdownMenuItem<FeedbackTopicEnum>> getDropdownItems(){
    return [
      const DropdownMenuItem(
        value: FeedbackTopicEnum.bugReport,
        child: Text('Сообщение о баге или ошибке в приложении'),
      ),

      const DropdownMenuItem(
        value: FeedbackTopicEnum.featureRequest,
        child: Text('Запрос на добавление новой функции'),
      ),

      const DropdownMenuItem(
        value: FeedbackTopicEnum.uiUx,
        child: Text('Вопросы c удобством использования'),
      ),
      const DropdownMenuItem(
        value: FeedbackTopicEnum.performance,
        child: Text('Вопросы с производительностью приложения'),
      ),
      const DropdownMenuItem(
        value: FeedbackTopicEnum.accountIssues,
        child: Text('Проблемы с учетной записью пользователя'),
      ),
      const DropdownMenuItem(
        value: FeedbackTopicEnum.paymentIssues,
        child: Text('Проблемы с оплатой или подпиской'),
      ),
      const DropdownMenuItem(
        value: FeedbackTopicEnum.generalFeedback,
        child: Text('Общие отзывы или предложения'),
      ),
      const DropdownMenuItem(
        value: FeedbackTopicEnum.other,
        child: Text('Другое'),
      ),
    ];
  }

  FeedbackTopicEnum _getTopicFromString({required String topicEnumInString}){
    switch (topicEnumInString){
      case 'bugReport': return FeedbackTopicEnum.bugReport;
      case 'featureRequest': return FeedbackTopicEnum.featureRequest;
      case 'uiUx': return FeedbackTopicEnum.uiUx;
      case 'performance': return FeedbackTopicEnum.performance;
      case 'accountIssues': return FeedbackTopicEnum.accountIssues;
      case 'paymentIssues': return FeedbackTopicEnum.paymentIssues;
      case 'generalFeedback': return FeedbackTopicEnum.generalFeedback;
      case 'other': return FeedbackTopicEnum.other;
      default: return FeedbackTopicEnum.other;
    }
  }


}