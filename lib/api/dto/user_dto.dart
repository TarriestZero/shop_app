import 'package:json_annotation/json_annotation.dart';

part 'user_dto.g.dart';

/// Пользователь из API. Ответы на запись могут содержать сокращённые данные.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class UserDto {
  const UserDto({
    required this.id,
    this.email,
    this.username,
    this.password,
    this.name,
    this.address,
    this.phone,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);

  final int id;
  final String? email;
  final String? username;
  final String? password;
  final UserNameDto? name;
  final UserAddressDto? address;
  final String? phone;

  Map<String, dynamic> toJson() => _$UserDtoToJson(this);
}

@JsonSerializable(includeIfNull: false)
class UserNameDto {
  const UserNameDto({this.firstName, this.lastName});

  factory UserNameDto.fromJson(Map<String, dynamic> json) =>
      _$UserNameDtoFromJson(json);

  @JsonKey(name: 'firstname')
  final String? firstName;
  @JsonKey(name: 'lastname')
  final String? lastName;

  Map<String, dynamic> toJson() => _$UserNameDtoToJson(this);
}

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class UserAddressDto {
  const UserAddressDto({
    this.city,
    this.street,
    this.number,
    this.zipcode,
    this.geolocation,
  });

  factory UserAddressDto.fromJson(Map<String, dynamic> json) =>
      _$UserAddressDtoFromJson(json);

  final String? city;
  final String? street;
  final int? number;
  final String? zipcode;
  final UserGeolocationDto? geolocation;

  Map<String, dynamic> toJson() => _$UserAddressDtoToJson(this);
}

@JsonSerializable(includeIfNull: false)
class UserGeolocationDto {
  const UserGeolocationDto({this.latitude, this.longitude});

  factory UserGeolocationDto.fromJson(Map<String, dynamic> json) =>
      _$UserGeolocationDtoFromJson(json);

  @JsonKey(name: 'lat')
  final String? latitude;
  @JsonKey(name: 'long')
  final String? longitude;

  Map<String, dynamic> toJson() => _$UserGeolocationDtoToJson(this);
}

/// Поля для создания и изменения пользователя, включая частичное обновление.
@JsonSerializable(explicitToJson: true, includeIfNull: false)
class UserRequestDto {
  const UserRequestDto({
    this.email,
    this.username,
    this.password,
    this.name,
    this.address,
    this.phone,
  });

  factory UserRequestDto.fromJson(Map<String, dynamic> json) =>
      _$UserRequestDtoFromJson(json);

  final String? email;
  final String? username;
  final String? password;
  final UserNameDto? name;
  final UserAddressDto? address;
  final String? phone;

  Map<String, dynamic> toJson() => _$UserRequestDtoToJson(this);
}
