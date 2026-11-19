// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDto _$UserDtoFromJson(Map<String, dynamic> json) => UserDto(
  id: (json['id'] as num).toInt(),
  email: json['email'] as String?,
  username: json['username'] as String?,
  password: json['password'] as String?,
  name: json['name'] == null
      ? null
      : UserNameDto.fromJson(json['name'] as Map<String, dynamic>),
  address: json['address'] == null
      ? null
      : UserAddressDto.fromJson(json['address'] as Map<String, dynamic>),
  phone: json['phone'] as String?,
);

Map<String, dynamic> _$UserDtoToJson(UserDto instance) => <String, dynamic>{
  'id': instance.id,
  'email': ?instance.email,
  'username': ?instance.username,
  'password': ?instance.password,
  'name': ?instance.name?.toJson(),
  'address': ?instance.address?.toJson(),
  'phone': ?instance.phone,
};

UserNameDto _$UserNameDtoFromJson(Map<String, dynamic> json) => UserNameDto(
  firstName: json['firstname'] as String?,
  lastName: json['lastname'] as String?,
);

Map<String, dynamic> _$UserNameDtoToJson(UserNameDto instance) =>
    <String, dynamic>{
      'firstname': ?instance.firstName,
      'lastname': ?instance.lastName,
    };

UserAddressDto _$UserAddressDtoFromJson(Map<String, dynamic> json) =>
    UserAddressDto(
      city: json['city'] as String?,
      street: json['street'] as String?,
      number: (json['number'] as num?)?.toInt(),
      zipcode: json['zipcode'] as String?,
      geolocation: json['geolocation'] == null
          ? null
          : UserGeolocationDto.fromJson(
              json['geolocation'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$UserAddressDtoToJson(UserAddressDto instance) =>
    <String, dynamic>{
      'city': ?instance.city,
      'street': ?instance.street,
      'number': ?instance.number,
      'zipcode': ?instance.zipcode,
      'geolocation': ?instance.geolocation?.toJson(),
    };

UserGeolocationDto _$UserGeolocationDtoFromJson(Map<String, dynamic> json) =>
    UserGeolocationDto(
      latitude: json['lat'] as String?,
      longitude: json['long'] as String?,
    );

Map<String, dynamic> _$UserGeolocationDtoToJson(UserGeolocationDto instance) =>
    <String, dynamic>{'lat': ?instance.latitude, 'long': ?instance.longitude};

UserRequestDto _$UserRequestDtoFromJson(Map<String, dynamic> json) =>
    UserRequestDto(
      email: json['email'] as String?,
      username: json['username'] as String?,
      password: json['password'] as String?,
      name: json['name'] == null
          ? null
          : UserNameDto.fromJson(json['name'] as Map<String, dynamic>),
      address: json['address'] == null
          ? null
          : UserAddressDto.fromJson(json['address'] as Map<String, dynamic>),
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$UserRequestDtoToJson(UserRequestDto instance) =>
    <String, dynamic>{
      'email': ?instance.email,
      'username': ?instance.username,
      'password': ?instance.password,
      'name': ?instance.name?.toJson(),
      'address': ?instance.address?.toJson(),
      'phone': ?instance.phone,
    };
