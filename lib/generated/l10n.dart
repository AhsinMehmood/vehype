// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Vehype`
  String get app_name {
    return Intl.message(
      'Vehype',
      name: 'app_name',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `I'm vehicle owner`
  String get imVehycleOwner {
    return Intl.message(
      'I\'m vehicle owner',
      name: 'imVehycleOwner',
      desc: '',
      args: [],
    );
  }

  /// `I'm service owner`
  String get imServiceOwner {
    return Intl.message(
      'I\'m service owner',
      name: 'imServiceOwner',
      desc: '',
      args: [],
    );
  }

  /// `Canceled orders`
  String get canceledOrders {
    return Intl.message(
      'Canceled orders',
      name: 'canceledOrders',
      desc: '',
      args: [],
    );
  }

  /// `History`
  String get history {
    return Intl.message(
      'History',
      name: 'history',
      desc: '',
      args: [],
    );
  }

  /// `Help`
  String get help {
    return Intl.message(
      'Help',
      name: 'help',
      desc: '',
      args: [],
    );
  }

  /// `Information`
  String get information {
    return Intl.message(
      'Information',
      name: 'information',
      desc: '',
      args: [],
    );
  }

  /// `Role`
  String get role {
    return Intl.message(
      'Role',
      name: 'role',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message(
      'Login',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Garage`
  String get garage {
    return Intl.message(
      'Garage',
      name: 'garage',
      desc: '',
      args: [],
    );
  }

  /// `User is not found`
  String get userIsNotFound {
    return Intl.message(
      'User is not found',
      name: 'userIsNotFound',
      desc: '',
      args: [],
    );
  }

  /// `User profile is not found`
  String get userProfileIsNotFound {
    return Intl.message(
      'User profile is not found',
      name: 'userProfileIsNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `Forgot password`
  String get forgotPassword {
    return Intl.message(
      'Forgot password',
      name: 'forgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `Password can't be less six symbols`
  String get passwordCantBeLessSixSymbol {
    return Intl.message(
      'Password can\'t be less six symbols',
      name: 'passwordCantBeLessSixSymbol',
      desc: '',
      args: [],
    );
  }

  /// `Password can't be empty`
  String get passwordCantBeEmpty {
    return Intl.message(
      'Password can\'t be empty',
      name: 'passwordCantBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Email can't be empty`
  String get emailCantBeEmpty {
    return Intl.message(
      'Email can\'t be empty',
      name: 'emailCantBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Role in system is not defined`
  String get userRoleIsNotDefined {
    return Intl.message(
      'Role in system is not defined',
      name: 'userRoleIsNotDefined',
      desc: '',
      args: [],
    );
  }

  /// `Dark`
  String get dark {
    return Intl.message(
      'Dark',
      name: 'dark',
      desc: '',
      args: [],
    );
  }

  /// `Light`
  String get light {
    return Intl.message(
      'Light',
      name: 'light',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get english {
    return Intl.message(
      'English',
      name: 'english',
      desc: '',
      args: [],
    );
  }

  /// `Russian`
  String get russian {
    return Intl.message(
      'Russian',
      name: 'russian',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get theme {
    return Intl.message(
      'Theme',
      name: 'theme',
      desc: '',
      args: [],
    );
  }

  /// `Response body from server is empty`
  String get httpResponseBodyIsNull {
    return Intl.message(
      'Response body from server is empty',
      name: 'httpResponseBodyIsNull',
      desc: '',
      args: [],
    );
  }

  /// `Connection to server is failed`
  String get connectionToServerIsFailed {
    return Intl.message(
      'Connection to server is failed',
      name: 'connectionToServerIsFailed',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Send`
  String get send {
    return Intl.message(
      'Send',
      name: 'send',
      desc: '',
      args: [],
    );
  }

  /// `Ok`
  String get ok {
    return Intl.message(
      'Ok',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `Error while parsing web service data`
  String get errorWhileParsingWebServiceData {
    return Intl.message(
      'Error while parsing web service data',
      name: 'errorWhileParsingWebServiceData',
      desc: '',
      args: [],
    );
  }

  /// `Error while parsing web service response`
  String get errorWhileParsingWebServiceResponse {
    return Intl.message(
      'Error while parsing web service response',
      name: 'errorWhileParsingWebServiceResponse',
      desc: '',
      args: [],
    );
  }

  /// `Confirmation code sent to email`
  String get confirmationCodeSent {
    return Intl.message(
      'Confirmation code sent to email',
      name: 'confirmationCodeSent',
      desc: '',
      args: [],
    );
  }

  /// `Code`
  String get code {
    return Intl.message(
      'Code',
      name: 'code',
      desc: '',
      args: [],
    );
  }

  /// `Field can't be empty`
  String get fieldCantBeEmpty {
    return Intl.message(
      'Field can\'t be empty',
      name: 'fieldCantBeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Your email is not found`
  String get yourEmailIsNotFound {
    return Intl.message(
      'Your email is not found',
      name: 'yourEmailIsNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message(
      'Confirm',
      name: 'confirm',
      desc: '',
      args: [],
    );
  }

  /// `Email confirmed`
  String get emailConfirmed {
    return Intl.message(
      'Email confirmed',
      name: 'emailConfirmed',
      desc: '',
      args: [],
    );
  }

  /// `While saving current user, occurred error`
  String get savingUserError {
    return Intl.message(
      'While saving current user, occurred error',
      name: 'savingUserError',
      desc: '',
      args: [],
    );
  }

  /// `Adding a new user in data base is failed`
  String get addingNewUserIsFailed {
    return Intl.message(
      'Adding a new user in data base is failed',
      name: 'addingNewUserIsFailed',
      desc: '',
      args: [],
    );
  }

  /// `Log Out`
  String get logout {
    return Intl.message(
      'Log Out',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to Log Out?`
  String get areYouSureLogout {
    return Intl.message(
      'Are you sure you want to Log Out?',
      name: 'areYouSureLogout',
      desc: '',
      args: [],
    );
  }

  /// `Something happend while logout`
  String get somethingHappendLogout {
    return Intl.message(
      'Something happend while logout',
      name: 'somethingHappendLogout',
      desc: '',
      args: [],
    );
  }

  /// `Registration`
  String get registration {
    return Intl.message(
      'Registration',
      name: 'registration',
      desc: '',
      args: [],
    );
  }

  /// `Login with Google`
  String get loginWithGoogle {
    return Intl.message(
      'Login with Google',
      name: 'loginWithGoogle',
      desc: '',
      args: [],
    );
  }

  /// `Login with Google`
  String get loginWithApple {
    return Intl.message(
      'Login with Apple',
      name: 'loginWithApple',
      desc: '',
      args: [],
    );
  }

  /// `Passwords in not match`
  String get passwordsIsNotMatch {
    return Intl.message(
      'Passwords in not match',
      name: 'passwordsIsNotMatch',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message(
      'Email',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  /// `Change`
  String get change {
    return Intl.message(
      'Change',
      name: 'change',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message(
      'Name',
      name: 'name',
      desc: '',
      args: [],
    );
  }

  /// `Phone`
  String get phone {
    return Intl.message(
      'Phone',
      name: 'phone',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get description {
    return Intl.message(
      'Description',
      name: 'description',
      desc: '',
      args: [],
    );
  }

  /// `Request token is not found`
  String get requestTokenIsNotFound {
    return Intl.message(
      'Request token is not found',
      name: 'requestTokenIsNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Resource is not found`
  String get resourceIsNotFound {
    return Intl.message(
      'Resource is not found',
      name: 'resourceIsNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `Profile's id is not found`
  String get profileIdIsNotFound {
    return Intl.message(
      'Profile\'s id is not found',
      name: 'profileIdIsNotFound',
      desc: '',
      args: [],
    );
  }

  /// `During saving current user profile, occurred error`
  String get savingUserProfileError {
    return Intl.message(
      'During saving current user profile, occurred error',
      name: 'savingUserProfileError',
      desc: '',
      args: [],
    );
  }

  /// `Gallery`
  String get galerry {
    return Intl.message(
      'Gallery',
      name: 'galerry',
      desc: '',
      args: [],
    );
  }

  /// `Camera`
  String get camera {
    return Intl.message(
      'Camera',
      name: 'camera',
      desc: '',
      args: [],
    );
  }

  /// `Additional images`
  String get additionalImages {
    return Intl.message(
      'Additional images',
      name: 'additionalImages',
      desc: '',
      args: [],
    );
  }

  /// `Licences`
  String get licences {
    return Intl.message(
      'Licences',
      name: 'licences',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get add {
    return Intl.message(
      'Add',
      name: 'add',
      desc: '',
      args: [],
    );
  }

  /// `Image is not found`
  String get imageIsNotFound {
    return Intl.message(
      'Image is not found',
      name: 'imageIsNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Contacts`
  String get contacts {
    return Intl.message(
      'Contacts',
      name: 'contacts',
      desc: '',
      args: [],
    );
  }

  /// `Something wrong`
  String get somethingWrong {
    return Intl.message(
      'Something wrong',
      name: 'somethingWrong',
      desc: '',
      args: [],
    );
  }

  /// `While saving`
  String get whileSaving {
    return Intl.message(
      'While saving',
      name: 'whileSaving',
      desc: '',
      args: [],
    );
  }

  /// `Avatar`
  String get avatar {
    return Intl.message(
      'Avatar',
      name: 'avatar',
      desc: '',
      args: [],
    );
  }

  /// `the`
  String get the {
    return Intl.message(
      'the',
      name: 'the',
      desc: '',
      args: [],
    );
  }

  /// `Services`
  String get services {
    return Intl.message(
      'Services',
      name: 'services',
      desc: '',
      args: [],
    );
  }

  /// `Additional services`
  String get additionalServices {
    return Intl.message(
      'Additional services',
      name: 'additionalServices',
      desc: '',
      args: [],
    );
  }

  /// `Apply`
  String get apply {
    return Intl.message(
      'Apply',
      name: 'apply',
      desc: '',
      args: [],
    );
  }

  /// `Empty`
  String get empty {
    return Intl.message(
      'Empty',
      name: 'empty',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message(
      'Search',
      name: 'search',
      desc: '',
      args: [],
    );
  }

  /// `Body style`
  String get bodyStyle {
    return Intl.message(
      'Body style',
      name: 'bodyStyle',
      desc: '',
      args: [],
    );
  }

  /// `Make`
  String get make {
    return Intl.message(
      'Make',
      name: 'make',
      desc: '',
      args: [],
    );
  }

  /// `Year`
  String get year {
    return Intl.message(
      'Year',
      name: 'year',
      desc: '',
      args: [],
    );
  }

  /// `Model`
  String get model {
    return Intl.message(
      'Model',
      name: 'model',
      desc: '',
      args: [],
    );
  }

  /// `Note`
  String get note {
    return Intl.message(
      'Note',
      name: 'note',
      desc: '',
      args: [],
    );
  }

  /// `VIN`
  String get vin {
    return Intl.message(
      'VIN',
      name: 'vin',
      desc: '',
      args: [],
    );
  }

  /// `Image`
  String get image {
    return Intl.message(
      'Image',
      name: 'image',
      desc: '',
      args: [],
    );
  }

  /// `Remove`
  String get remove {
    return Intl.message(
      'Remove',
      name: 'remove',
      desc: '',
      args: [],
    );
  }

  /// `Create`
  String get create {
    return Intl.message(
      'Create',
      name: 'create',
      desc: '',
      args: [],
    );
  }

  /// `Vehicle`
  String get vehicle {
    return Intl.message(
      'Vehicle',
      name: 'vehicle',
      desc: '',
      args: [],
    );
  }

  /// `Service`
  String get service {
    return Intl.message(
      'Service',
      name: 'service',
      desc: '',
      args: [],
    );
  }

  /// `Location`
  String get location {
    return Intl.message(
      'Location',
      name: 'location',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  /// `Offers`
  String get offers {
    return Intl.message(
      'Offers',
      name: 'offers',
      desc: '',
      args: [],
    );
  }

  /// `Details`
  String get details {
    return Intl.message(
      'Details',
      name: 'details',
      desc: '',
      args: [],
    );
  }

  /// `In progress`
  String get inProgress {
    return Intl.message(
      'In progress',
      name: 'inProgress',
      desc: '',
      args: [],
    );
  }

  /// `Started`
  String get started {
    return Intl.message(
      'Started',
      name: 'started',
      desc: '',
      args: [],
    );
  }

  /// `Repaired`
  String get repaired {
    return Intl.message(
      'Repaired',
      name: 'repaired',
      desc: '',
      args: [],
    );
  }

  /// `Canceled`
  String get canceled {
    return Intl.message(
      'Canceled',
      name: 'canceled',
      desc: '',
      args: [],
    );
  }

  /// `Request id is not found`
  String get requestIdIsNotFound {
    return Intl.message(
      'Request id is not found',
      name: 'requestIdIsNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Set vehicle`
  String get setVehicle {
    return Intl.message(
      'Set vehicle',
      name: 'setVehicle',
      desc: '',
      args: [],
    );
  }

  /// `Set service`
  String get setService {
    return Intl.message(
      'Set service',
      name: 'setService',
      desc: '',
      args: [],
    );
  }

  /// `Set your location`
  String get setYourLocation {
    return Intl.message(
      'Set your location',
      name: 'setYourLocation',
      desc: '',
      args: [],
    );
  }

  /// `This request is readonly`
  String get requestIsReadonly {
    return Intl.message(
      'This request is readonly',
      name: 'requestIsReadonly',
      desc: '',
      args: [],
    );
  }

  /// `Unfortunately after create request you can modify only note and images`
  String get requestIsReadonlyNotification {
    return Intl.message(
      'Unfortunately after create request you can modify only note and images',
      name: 'requestIsReadonlyNotification',
      desc: '',
      args: [],
    );
  }

  /// `Reached your limit for file uploads`
  String get reachedUploadLimitNotification {
    return Intl.message(
      'Reached your limit for file uploads',
      name: 'reachedUploadLimitNotification',
      desc: '',
      args: [],
    );
  }

  /// `Start`
  String get start {
    return Intl.message(
      'Start',
      name: 'start',
      desc: '',
      args: [],
    );
  }

  /// `End`
  String get end {
    return Intl.message(
      'End',
      name: 'end',
      desc: '',
      args: [],
    );
  }

  /// `Date`
  String get date {
    return Intl.message(
      'Date',
      name: 'date',
      desc: '',
      args: [],
    );
  }

  /// `Price`
  String get price {
    return Intl.message(
      'Price',
      name: 'price',
      desc: '',
      args: [],
    );
  }

  /// `Decline`
  String get decline {
    return Intl.message(
      'Decline',
      name: 'decline',
      desc: '',
      args: [],
    );
  }

  /// `Accept`
  String get accept {
    return Intl.message(
      'Accept',
      name: 'accept',
      desc: '',
      args: [],
    );
  }

  /// `New`
  String get New {
    return Intl.message(
      'New',
      name: 'New',
      desc: '',
      args: [],
    );
  }

  /// `Rate`
  String get rate {
    return Intl.message(
      'Rate',
      name: 'rate',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message(
      'Close',
      name: 'close',
      desc: '',
      args: [],
    );
  }

  /// `Business name`
  String get businessName {
    return Intl.message(
      'Business name',
      name: 'businessName',
      desc: '',
      args: [],
    );
  }

  /// `Evaluate the work of the service`
  String get evaluateWorkService {
    return Intl.message(
      'Evaluate the work of the service',
      name: 'evaluateWorkService',
      desc: '',
      args: [],
    );
  }

  /// `Dialogs`
  String get dialogs {
    return Intl.message(
      'Dialogs',
      name: 'dialogs',
      desc: '',
      args: [],
    );
  }

  /// `Messages`
  String get messages {
    return Intl.message(
      'Messages',
      name: 'messages',
      desc: '',
      args: [],
    );
  }

  /// `Offered`
  String get offered {
    return Intl.message(
      'Offered',
      name: 'offered',
      desc: '',
      args: [],
    );
  }

  /// `Make an offer`
  String get makeOffer {
    return Intl.message(
      'Make an offer',
      name: 'makeOffer',
      desc: '',
      args: [],
    );
  }

  /// `Chat`
  String get chat {
    return Intl.message(
      'Chat',
      name: 'chat',
      desc: '',
      args: [],
    );
  }

  /// `Client`
  String get client {
    return Intl.message(
      'Client',
      name: 'client',
      desc: '',
      args: [],
    );
  }

  /// `Images`
  String get images {
    return Intl.message(
      'Images',
      name: 'images',
      desc: '',
      args: [],
    );
  }

  /// `Please enter data`
  String get enterData {
    return Intl.message(
      'Please enter data',
      name: 'enterData',
      desc: '',
      args: [],
    );
  }

  /// `Incorect end date`
  String get incorectEndDate {
    return Intl.message(
      'Incorect end date',
      name: 'incorectEndDate',
      desc: '',
      args: [],
    );
  }

  /// `Location service is turn off`
  String get locationServiceIsTurnOff {
    return Intl.message(
      'Location service is turn off',
      name: 'locationServiceIsTurnOff',
      desc: '',
      args: [],
    );
  }

  /// `Enable`
  String get enable {
    return Intl.message(
      'Enable',
      name: 'enable',
      desc: '',
      args: [],
    );
  }

  /// `Allow Vehype to access your location`
  String get allowYourLocation {
    return Intl.message(
      'Allow Vehype to access your location',
      name: 'allowYourLocation',
      desc: '',
      args: [],
    );
  }

  /// `Distance`
  String get distance {
    return Intl.message(
      'Distance',
      name: 'distance',
      desc: '',
      args: [],
    );
  }

  /// `Business`
  String get business {
    return Intl.message(
      'Business',
      name: 'business',
      desc: '',
      args: [],
    );
  }

  /// `Access to canceled order in`
  String get accessToCanceledOrderIn {
    return Intl.message(
      'Access to canceled order in',
      name: 'accessToCanceledOrderIn',
      desc: '',
      args: [],
    );
  }

  /// `Unfortunately you can't remove request, before time expiration, but you have opportunity to ask service owner to rate you, and you can remove your request earlier`
  String get warningRemoveCanceledRequestBeforeTimeExperation {
    return Intl.message(
      'Unfortunately you can\'t remove request, before time expiration, but you have opportunity to ask service owner to rate you, and you can remove your request earlier',
      name: 'warningRemoveCanceledRequestBeforeTimeExperation',
      desc: '',
      args: [],
    );
  }

  /// `Notification manager has not been implemented`
  String get notificationManagerHasNotBeenImplemented {
    return Intl.message(
      'Notification manager has not been implemented',
      name: 'notificationManagerHasNotBeenImplemented',
      desc: '',
      args: [],
    );
  }

  /// `Notification service has not been implemented`
  String get notificationServiceHasNotBeenImplemented {
    return Intl.message(
      'Notification service has not been implemented',
      name: 'notificationServiceHasNotBeenImplemented',
      desc: '',
      args: [],
    );
  }

  /// `Notification token is not found`
  String get notificationTokenIsNotFound {
    return Intl.message(
      'Notification token is not found',
      name: 'notificationTokenIsNotFound',
      desc: '',
      args: [],
    );
  }

  /// `Required notification persmissions`
  String get requiredNotificationPermissions {
    return Intl.message(
      'Required notification persmissions',
      name: 'requiredNotificationPermissions',
      desc: '',
      args: [],
    );
  }

  /// `Error while registration notification token on backend side`
  String get errorWhileRegistrationTokenOnServer {
    return Intl.message(
      'Error while registration notification token on backend side',
      name: 'errorWhileRegistrationTokenOnServer',
      desc: '',
      args: [],
    );
  }

  /// `Application version`
  String get appVersion {
    return Intl.message(
      'Application version',
      name: 'appVersion',
      desc: '',
      args: [],
    );
  }

  /// `Get in touch with us`
  String get getInTouch {
    return Intl.message(
      'Get in touch with us',
      name: 'getInTouch',
      desc: '',
      args: [],
    );
  }

  /// `Send us a message`
  String get sendUsMessage {
    return Intl.message(
      'Send us a message',
      name: 'sendUsMessage',
      desc: '',
      args: [],
    );
  }

  /// `About us`
  String get aboutUs {
    return Intl.message(
      'About us',
      name: 'aboutUs',
      desc: '',
      args: [],
    );
  }

  /// `With any inquiries about your account or app functionality, please contact us at`
  String get inquiriesAboutYourAccountAppFunctionality {
    return Intl.message(
      'With any inquiries about your account or app functionality, please contact us at',
      name: 'inquiriesAboutYourAccountAppFunctionality',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete your profile from Vehype system`
  String get areYouSureRemoveProfile {
    return Intl.message(
      'Are you sure you want to delete your profile from Vehype system',
      name: 'areYouSureRemoveProfile',
      desc: '',
      args: [],
    );
  }

  /// `User`
  String get user {
    return Intl.message(
      'User',
      name: 'user',
      desc: '',
      args: [],
    );
  }

  /// `From`
  String get from {
    return Intl.message(
      'From',
      name: 'from',
      desc: '',
      args: [],
    );
  }

  /// `System`
  String get system {
    return Intl.message(
      'System',
      name: 'system',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `Account`
  String get account {
    return Intl.message(
      'Account',
      name: 'account',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ru'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
