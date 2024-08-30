enum FeedbackStatusEnum {
  received,       // Сообщение получено
  inProgress,     // Сообщение обрабатывается
  resolved,       // Проблема решена
  dismissed,      // Сообщение отклонено
  awaitingResponse, // Ожидается ответ от пользователя
  escalated,      // Сообщение передано на более высокий уровень
  closed          // Обработка завершена
}

enum FeedbackTopicEnum {
  bugReport,          // Сообщение о баге или ошибке в приложении
  featureRequest,     // Запрос на добавление новой функции
  uiUx,               // Вопросы, связанные с пользовательским интерфейсом и удобством использования
  performance,        // Вопросы, связанные с производительностью приложения
  accountIssues,      // Проблемы, связанные с учетной записью пользователя
  paymentIssues,      // Проблемы с оплатой или подпиской
  generalFeedback,    // Общие отзывы или предложения
  other               // Другое
}