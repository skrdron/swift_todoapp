//
//  ViewController.swift
//  TodoApp
//
//  Created by 櫻田龍之助 on 2024/04/05.
//

import UIKit

//todoの型定義
struct TodoItem: Codable {
    var title:String
    var completed:Bool
}

//todoを管理するtodolistの型定義
struct TodoList: Codable{
    var items:[TodoItem]
}

//Todoのリストを保存するクラス
class TodoListController{
    //以下で生成したTodoListを自身のTodoListに入れて更新
    var todoList:TodoList
    
    //初期化
    init(){
        //最初にTodoListを生成
        let defaults = UserDefaults.standard
        if let saveData = defaults.data(forKey: "TodoList"),let savedList = try? JSONDecoder().decode(TodoList.self, from :saveData){
            todoList = savedList
        }else{
            todoList = TodoList(items:[])
        }
    }
    
    //セルの個数を返す
    var todoItems:[TodoItem]{
        return  todoList.items
    }
    
    //Todoを追加
    func addItem(title:String){
        let newItem = TodoItem(title: title, completed:false)
        todoList.items.append(newItem)
        save()
    }
    
    //Todoを削除
    func removeItem(at index: Int){
        todoList.items.remove(at: index)
        save()
    }
    
    //Todoの達成フラグを反転させる
    func toggleCompleted(at index: Int){
        todoList.items[index].completed.toggle()
        save()
    }
    
    //Todoリストがアプリを消してもデータを保存する
    func save(){
        let defaults = UserDefaults.standard
        if let encodelist = try? JSONEncoder().encode(todoList){
            defaults.setValue(encodelist ,forKey:"TodoList")
        }
    }
}

class TodoListViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    var todoListController = TodoListController()

    // +ボタンの選択の処理
    @IBAction func addTodoItem(_ sender: Any) {
        guard let title = textField.text, !title.isEmpty else { return }
        todoListController.addItem(title: title)
        tableView.reloadData()
        textField.text = ""
    }
}

/*
 Extensionを使ってカスタムセルを登録＆生成
 [リスト表示させるためのデータとセルを管理するためのデリゲートメソッドを提供するためのプロトコル]
*/
extension TodoListViewController: UITableViewDataSource{
    //セルの個数 = 登録したtodoの個数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoListController.todoItems.count
    }
    
    //セルの生成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        //作るセルを選択してそれを変数に代入
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        //todoListControllerの配列の何番目かを指定しそれを変数に代入
        let todoItem = todoListController.todoItems[indexPath.row]
        //選択したセルに取得したtodoのデータを入れてあげる
        cell.textLabel?.text = todoItem.title
        cell.accessoryType = todoItem.completed ? .checkmark : .none
        //セルを返す
        return cell
    }
    
 
    //セルをスワイプで削除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            todoListController.removeItem(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

/*
 Extensionを使ってカスタムセルを登録＆生成
 [UITableView の操作イベントをハンドリングするプロトコル]
*/
extension TodoListViewController: UITableViewDelegate{
    //選択時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        todoListController.toggleCompleted(at: indexPath.row)
        tableView.reloadData()
    }
}
