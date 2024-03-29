import 'package:dw_barbershop/src/core/fp/either.dart';
import 'package:dw_barbershop/src/core/restClient/rest_client.dart';
import 'package:dw_barbershop/src/core/ui/barbershop_nav_global_key.dart';
import 'package:dw_barbershop/src/model/barbershop_model.dart';
import 'package:dw_barbershop/src/repositories/barbershop/barbershop_repository_impl.dart';
import 'package:dw_barbershop/src/repositories/schedule/schedule_repository.dart';
import 'package:dw_barbershop/src/repositories/schedule/schedule_repository_impl.dart';
import 'package:dw_barbershop/src/repositories/user/user_repository.dart';
import 'package:dw_barbershop/src/repositories/user/user_repository_impl.dart';
import 'package:dw_barbershop/src/services/user_login/user_login_service.dart';
import 'package:dw_barbershop/src/services/user_login/user_login_service_impl.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/user_model.dart';
import '../../repositories/barbershop/barbershop_repository.dart';

part 'application_providers.g.dart';

/*providers(provedores globais, instancias de classe que vao ser usadas pela nossa aplicacao como um todo */

/*metodo de nivel superior com RestClient que recebe no construtor um ref 
que vai ser uma referencia do Riverpod - retornar a instancia de RestClient */

//dart run build_runner watch -d
@Riverpod(keepAlive: true)
RestClient restClient(RestClientRef ref) => RestClient();

@Riverpod(keepAlive: true)
/*repositorio do usuario, da barbearia e de agendamentos, precisarão usar o restClientProvider. */
UserRepository userRepository(UserRepositoryRef ref) =>
    UserRepositoryImpl(restClient: ref.read(restClientProvider));

@Riverpod(keepAlive: true)
UserLoginService userLoginService(UserLoginServiceRef ref) =>
    UserLoginServiceImpl(userRepository: ref.read(userRepositoryProvider));

/*para criar o provider do 'me', para chamar em qlqr lugar, como no loginVM.
Esse é mais complexo: vamos pegar o resultado do .me do userRepositoryProvider, 
e isso vai nos trazer o UserModel ou uma excepion. */
@Riverpod(keepAlive: true)
Future<UserModel> getMe(GetMeRef ref) async {
  final result = await ref.watch(userRepositoryProvider).me();

  return switch (result) {
    Success(value: final userModel) => userModel,
    Failure(:final exception) => throw exception,
  };
}

//assim como o User, também faremos o barbershoRep e getMyBarbershop.

@Riverpod(keepAlive: true)
BarbershopRepository barbershopRepository(BarbershopRepositoryRef ref) =>
    BarbershopRepositoryImpl(restClient: ref.watch(restClientProvider));

@Riverpod(keepAlive: true)
Future<BarbershopModel> getMyBarbershop(GetMyBarbershopRef ref) async {
  //3- precisa do userModel corrente
  /*tem que ser o .futuro pq o userModel retorna um AsyncValue, o metodo 
  getMe é do tipo Future*/
  final userModel = await ref.watch(getMeProvider.future);
  //1- pegar a ref do repositorio
  final barbershopRepository = ref.watch(barbershopRepositoryProvider);
  //2- com o repositorio instanciado, vms usar o metodo getMyBarbershop de lá
  final result = await barbershopRepository.getMyBarbershop(userModel);

  return switch (result) {
    Success(value: final barbershop) => barbershop,
    Failure(:final exception) => throw exception
  };
}

/*nao precisa de keepAlive pq vai fazer uma acao de ponta a ponta 
e depois pode ser eliminado ou nao, o riverpod pode decidir*/
@riverpod
Future<void> logout(LogoutRef ref) async {
  //instancia de sharedPreferences
  final sp = await SharedPreferences.getInstance();
  //para poder eliminar todo o sharedPreferences
  sp.clear();

//invalida os caches
  ref.invalidate(getMeProvider);
  ref.invalidate(getMyBarbershopProvider);

/*navega pra tela de navegação. Como nao temos contexto, iremos usar a key global
-pushNamedandRemoveUntil pq nao importa aonde esteja, vamos "matar a tela atual"
e ir pra homePage*/
  Navigator.of(BarbershopNavGlobalKey.instance.navKey.currentContext!)
      .pushNamedAndRemoveUntil('/auth/login', (route) => false);
}

@riverpod
ScheduleRepository scheduleRepository(ScheduleRepositoryRef ref) =>
    ScheduleRepositoryImpl(restClient: ref.read(restClientProvider));
