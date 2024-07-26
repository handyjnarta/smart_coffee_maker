import 'package:flutter/material.dart';
import 'package:flutter_bluetooth/app/controllers/recipe_controller.dart';
import 'package:flutter_bluetooth/app/helper/popup_dialogs.dart';
import 'package:flutter_bluetooth/app/views/connection_view.dart';
import 'package:get/get.dart';
import '../../main.dart';
import 'data_logs_view.dart';
import 'recipes_view.dart';

final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

enum RecipePopupMenuItem { newRecipe, saveRecipe, loadRecipe }

class MainView extends StatelessWidget {
  const MainView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text("Marcoff Chat"),
        backgroundColor: const Color.fromARGB(199, 170, 84, 3),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
                right: 10.0,
                top: 10,
                bottom:
                    10), //padding: const EdgeInsets.only(right: 14.0, top: 10, bottom: 6),
            child: Obx(() {
              return Visibility(
                  visible: (ctrl.selectedTabIndex.value == 1 &&
                          ctrl.logs.value.isNotEmpty) ||
                      ctrl.selectedTabIndex.value == 2,
                  child: ctrl.selectedTabIndex.value == 1
                      ? Row(
                          children: [
                            // switch logs view as chat view or standard view
                            IconButton(
                                onPressed: () {
                                  ctrl.isLogAsChatView.value =
                                      !ctrl.isLogAsChatView.value;
                                },
                                icon: Icon(ctrl.isLogAsChatView.isTrue
                                    ? Icons.table_rows_rounded
                                    : Icons.chat)),

                            const SizedBox(
                              width: 40,
                            ),

                            InkWell(
                              onTap: () {
                                showConfirmDialog(
                                    context: context,
                                    title: 'Delete logs confirm',
                                    text: 'Delete all log?',
                                    onOkPressed: deleteLogs);
                              },
                              child: const Icon(Icons.delete),
                            ),
                          ],
                        )
                      :
                      // OutlinedButton(
                      //     onPressed: () {
                      //       const RecipesView().createNewRecipe(context);
                      //     },
                      //     style: buildButtonStyle(borderColor: Colors.grey, splashColor: Colors.yellow),
                      //     child: const Text('New Recipe', style: TextStyle(color: Colors.white),)
                      // ),
                      PopupMenuButton<RecipePopupMenuItem>(
                          onSelected: (RecipePopupMenuItem item) {
                          if (item == RecipePopupMenuItem.newRecipe) {
                            const RecipesView().createNewRecipe(context);
                          } else if (item == RecipePopupMenuItem.saveRecipe) {
                            if (RecipeController().recipeList.isNotEmpty) {
                              RecipeController().saveRecipeListIntoStorage();
                            } else {
                              null;
                            }
                          } else {
                            RecipeController().loadRecipeListFromStorage(
                                isLoadFromInitApp: false);
                          }
                        }, itemBuilder: (BuildContext context) {
                          return [
                            const PopupMenuItem<RecipePopupMenuItem>(
                              value: RecipePopupMenuItem.newRecipe,
                              child: Row(
                                children: [
                                  Text('New Recipe'),
                                  Expanded(
                                      child: SizedBox(
                                    width: 10,
                                  )),
                                  Icon(Icons.add_rounded,
                                      size: 20.0, color: Colors.black)
                                ],
                              ),
                            ),
                            PopupMenuItem<RecipePopupMenuItem>(
                              value: RecipePopupMenuItem.saveRecipe,
                              child: Row(
                                children: [
                                  Text(
                                    'Save to Cloud',
                                    style: TextStyle(
                                        color: RecipeController()
                                                .recipeList
                                                .isNotEmpty
                                            ? Colors.black
                                            : Colors.grey),
                                  ),
                                  const Expanded(
                                      child: SizedBox(
                                    width: 10,
                                  )),
                                  Icon(Icons.save_alt_outlined,
                                      size: 20.0,
                                      color: RecipeController()
                                              .recipeList
                                              .isNotEmpty
                                          ? Colors.black
                                          : Colors.grey)
                                ],
                              ),
                            ),
                            const PopupMenuItem<RecipePopupMenuItem>(
                              value: RecipePopupMenuItem.loadRecipe,
                              child: Row(
                                children: [
                                  Text('Load Recipe'),
                                  Expanded(
                                      child: SizedBox(
                                    width: 10,
                                  )),
                                  Icon(
                                    Icons.upload_outlined,
                                    size: 20.0,
                                    color: Colors.black,
                                  )
                                ],
                              ),
                            ),
                          ];
                        }));
            }),
          )
        ],
        bottom: TabBar(
          controller: ctrl.tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(
                icon: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bluetooth),
                SizedBox(
                  width: 2,
                ),
                Text('Link')
              ],
            )),
            Tab(
                icon: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.terminal),
                SizedBox(
                  width: 2,
                ),
                Text('Chat')
              ],
            )),
            Tab(
                icon: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.list_alt_outlined),
                SizedBox(
                  width: 2,
                ),
                Text('Resep')
              ],
            )),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height -
              AppBar().preferredSize.height -
              kToolbarHeight * 1.2,
          child: TabBarView(
            controller: ctrl.tabController,
            children: const [
              // bluetooth connection tab
              ConnectionView(),

              // Data logs tab
              DataLogs(),

              // recipe list tab
              RecipesView(),
            ],
          ),
        ),
      ),
    );
  }

  void deleteLogs() {
    Get.back();
    ctrl.logs.value.clear();
    ctrl.logs.refresh();
    debugPrint('[main_view] Logs deleted');
  }
}
