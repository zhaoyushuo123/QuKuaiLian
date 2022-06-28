// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.15 <0.9.0;

contract StudentContract {
    struct Student {
        uint256 id;
        string name;
        string sex;
        uint256 age;
        string dept;
    }

    address admin;
    Student[] students;
    uint256[] ids;
    uint256 count = 0;
    mapping(uint256 => uint256) indexMapping; // id映射index
    mapping(uint256 => bool) isExistMapping;

    constructor() {
        admin = msg.sender;
    }

    function insert(
        uint256 _id,
        string memory _name,
        string memory _sex,
        uint256 _age,
        string memory _dept
    ) public {
        require(msg.sender == admin);
        if (isExistMapping[_id]) {
            return;
        }
        Student memory student = Student(_id, _name, _sex, _age, _dept);
        students.push(student);
        ids.push(_id);
        indexMapping[_id] = count;
        isExistMapping[_id] = true;
        count += 1;
        emit Insert(_id);
    }

    event Insert(uint256 id);

    event Update(uint256 id);


    function exist_by_id(uint256 _id) public view returns (bool isExist) {
        return isExistMapping[_id];
    }

    function select_count() public view returns (uint256 _count) {
        return count;
    }

    function select_all_id() public view returns (uint256[] memory _ids) {
        return ids;
    }

    function select_id(uint256 _id) public view returns (Student memory) {
        require(isExistMapping[_id]);
        return students[indexMapping[_id]];
    }

    function delete_by_id(uint256 _id) public {
        require(msg.sender == admin);
        if (!isExistMapping[_id]) {
            return;
        }
        uint256 index = indexMapping[_id];
        uint256 lastStudentIndex = students.length-1;
        // 如果 要删除的是最后一个元素，直接pop
        if(index==lastStudentIndex){
            students.pop();
            ids.pop();
            delete indexMapping[_id];
        }else{
        // 否则 将最后一个元素移动到被删除元素的位置覆盖，再pop
            students[index]=students[lastStudentIndex];
            students.pop();
            ids[index]=ids[lastStudentIndex];
            ids.pop();
            // 修改被移动元素映射index
            indexMapping[ids[index]]=index;
            // 删除被删除元素的映射index
            delete indexMapping[_id];
        }
        count -= 1;
        // 修改被删除元素为不存在
        isExistMapping[_id] = false;
    }

    function get_id_by_min_age() public view returns (uint256 _id) {
        uint256 min_age = 100;
        uint256 min_age_id = 0;
        for (uint256 i = 0; i < students.length; i++) {
            if (students[i].age < min_age) {
                min_age = students[i].age;
                min_age_id = students[i].id;
            }
        }
        return min_age_id;
    }

    function update_dept_by_id(uint256 _id,string memory _dept) public{
        require(isExistMapping[_id]);
        students[indexMapping[_id]].dept = _dept;
        emit Update(_id);
    }
}
