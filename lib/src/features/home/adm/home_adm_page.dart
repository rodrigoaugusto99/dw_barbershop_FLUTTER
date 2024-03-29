import 'dart:developer';

import 'package:dw_barbershop/src/core/providers/application_providers.dart';
import 'package:dw_barbershop/src/core/ui/barbershop_icons.dart';
import 'package:dw_barbershop/src/core/ui/constants.dart';
import 'package:dw_barbershop/src/core/ui/widgets/barbershop_loader.dart';
import 'package:dw_barbershop/src/features/home/adm/home_adm_vm.dart';
import 'package:dw_barbershop/src/features/home/adm/widgets/home_employee_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/home_header.dart';
import 'home_adm_state.dart';

class HomeAdmPage extends ConsumerWidget {
  const HomeAdmPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //buscando o estado logo de cara
    final homeState = ref.watch(homeAdmVmProvider);
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: ColorsConstants.brown,
          onPressed: () async {
            await Navigator.of(context).pushNamed('/employee/register');
            ref.invalidate(getMeProvider);
            ref.invalidate(homeAdmVmProvider);
          },
          child: const CircleAvatar(
            backgroundColor: Colors.white,
            maxRadius: 12,
            child: Icon(
              BarbershopIcons.addEmployee,
              color: ColorsConstants.brown,
            ),
          ),
        ),
        //no body, chamar o homeState.when
        body: homeState.when(data: (HomeAdmState data) {
          return CustomScrollView(
            slivers: [
              //paras colocar widgets nao rolaveis.
              const SliverToBoxAdapter(
                child: HomeHeader(),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        HomeEmployeeTile(employee: data.employees[index]),
                    childCount: data.employees.length),
              ),
            ],
          );
        }, error: (Object error, StackTrace stackTrace) {
          log('Erro ao carregar colaboradores',
              error: error, stackTrace: stackTrace);
          return const Center(
            child: Text('Erro ao carregar página'),
          );
        }, loading: () {
          return const BarbershopLoader();
        }));
  }
}
