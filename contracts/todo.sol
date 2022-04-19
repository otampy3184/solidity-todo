// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract todo {

    // Todoリストの構造体
    struct Todo {
        string contents;
        bool is_opened;
        bool is_deleted;
    }

    // 複数のTodoからなるtodos
    Todo[] public todos;

    // idとaddressの紐付け
    mapping (uint => address) public todoToOwner;
    mapping (address => uint) todoCountByOwner;

    // コントラクトの呼び出し元のみが操作できるようにする
    modifier onlyMine(uint id) {
        require(todoToOwner[id] == msg.sender);
        _;
    }

    // 全Todoを返却する
    function getTODO() external view returns(uint[] memory) {
        // TODOが0だった場合は空の配列を返す
        if (todoCountByOwner[msg.sender] == 0) {
            uint[] memory emptyArray = new uint[](0);
            return emptyArray;
        }

    // arrayはMemoryからStrageを設定する必要がある
    uint[] memory result = new uint[](todoCountByOwner[msg.sender]);
    uint counter = 0;

    for (uint i = 0; i < todos.length; i++) {
        if (todoToOwner[i] == msg.sender && todos[i].is_deleted == false) {
            result[counter] = i;
            counter++;
        }
    }

    return result;
    }

    // 引数からTODOを作成しstorageに保存する
    function createTODO(string memory _contents) public returns(uint) {
        todos.push(Todo(_contents, true, false));
        uint id = todos.length - 1;
        todoToOwner[id] = msg.sender;

        // TODO数を増やす
        todoCountByOwner[msg.sender]++;

        return id;
    }

    function updateTODO(uint _id, bool _is_opened) public onlyMine(_id) {
        // 指定のIDのTODOをアップデートする
        todos[_id].is_opened = _is_opened;
    }

    function deleteTODO(uint _id) public onlyMine(_id) {
        require(todos[_id].is_deleted == false);

        // 自分のTODOを削除する
        todos[_id].is_deleted = true;

        // TODO数を減らす
        todoCountByOwner[msg.sender]--;
    }
}
