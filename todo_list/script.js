let currentFilter = 'all';

function getCleanToday() {
    const today = new Date();
    today.setHours(0,0,0,0);
    return today;
}

function getCurrentDateTime() {
    const now = new Date();
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const date = String(now.getDate()).padStart(2, '0');
    const hours = String(now.getHours()).padStart(2, '0');
    const minutes = String(now.getMinutes()).padStart(2, '0');
    return `${year}-${month}-${date} ${hours}:${minutes}`;
}

function calculateDDay(dueDateStr) {
    if (!dueDateStr) return '';
    const targetDate = new Date(dueDateStr);
    targetDate.setHours(0,0,0,0);
    const today = getCleanToday();
    
    const diffTime = targetDate - today;
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    
    if (diffDays === 0) return ' (D-Day)';
    if (diffDays > 0) return ` (D-${diffDays})`;
    return ` (만료 ${Math.abs(diffDays)}일 지남)`;
}

function updateEmptyNotice() {
    const mainContainer = document.getElementById('mainContainer');
    const emptyNotice = document.getElementById('emptyNotice');
    const groups = mainContainer.querySelectorAll('.todo-group');
    
    if (groups.length === 0) {
        if (!emptyNotice) {
            const notice = document.createElement('div');
            notice.id = 'emptyNotice';
            notice.className = 'empty-notice';
            notice.textContent = '아직 등록된 목록이 없습니다. 상단에서 할 일을 입력해보세요!';
            mainContainer.appendChild(notice);
        }
    } else {
        if (emptyNotice) emptyNotice.remove();
    }
}

function toggleGroupInputMode(selectedValue) {
    const groupNameInput = document.getElementById('newGroupNameInput');
    const groupColorSelect = document.getElementById('groupColorSelect');

    if (selectedValue === 'write_direct') {
        groupNameInput.disabled = false;
        groupNameInput.placeholder = "생성할 그룹 이름을 입력하세요";
        groupColorSelect.disabled = false;
    } else {
        groupNameInput.disabled = true;
        groupNameInput.value = "";
        groupNameInput.placeholder = "상단 드롭다운에서 선택된 그룹에 배정됩니다.";
        groupColorSelect.disabled = true;
    }
}

function handleSubmitTopForm() {
    const groupHistorySelect = document.getElementById('groupHistorySelect');
    const groupNameInput = document.getElementById('newGroupNameInput');
    const groupColorSelect = document.getElementById('groupColorSelect');
    const topTodoInput = document.getElementById('topTodoInput');
    const topTodoDate = document.getElementById('topTodoDate');

    const selectMode = groupHistorySelect.value;
    const todoText = topTodoInput.value.trim();
    const dueDateValue = topTodoDate.value; // 선택 안 할 시 빈 문자열('') 반환됨

    if (todoText === '') {
        alert('할 일 내용을 입력해주세요.');
        return;
    }

    let groupId = '';

    if (selectMode === 'write_direct') {
        const groupName = groupNameInput.value.trim();
        if (groupName === '') {
            alert('생성할 그룹 이름을 입력해주세요. 그룹 지정을 하지 않으려면 [그룹 미지정] 목록을 선택하시면 됩니다.');
            return;
        }

        const themeClass = groupColorSelect.value;
        groupId = 'group-' + Date.now();

        buildGroupContainer(groupId, groupName, themeClass);
        appendGroupToDropdown(groupId, groupName);

    } else if (selectMode === 'none_assigned') {
        groupId = 'group-none-assigned';
        const existingNoneGroup = document.getElementById(groupId);
        if (!existingNoneGroup) {
            buildGroupContainer(groupId, '기본 목록 (그룹 미지정)', 'theme-none');
        }
    } else {
        groupId = selectMode;
    }

    appendTodoItem(groupId, todoText, dueDateValue);

    topTodoInput.value = '';
    topTodoDate.value = '';
    if (selectMode === 'write_direct') {
        groupNameInput.value = '';
    }
}

function buildGroupContainer(groupId, groupName, themeClass) {
    const mainContainer = document.getElementById('mainContainer');
    const groupSection = document.createElement('section');
    groupSection.className = `todo-group ${themeClass}`;
    groupSection.id = groupId;
    
    const isNoneGroup = (groupId === 'group-none-assigned');
    groupSection.innerHTML = `
        <div class="group-header">
            <h2 class="group-title" onclick="enableEditGroup(this)">${groupName}</h2>
            <div class="group-controls">
                ${isNoneGroup ? '' : `
                <select class="theme-select" onchange="changeGroupTheme('${groupId}', this.value)">
                    <option value="theme-default" ${themeClass==='theme-default'?'selected':''}>주황 미색</option>
                    <option value="theme-yellow" ${themeClass==='theme-yellow'?'selected':''}>노랑 미색</option>
                    <option value="theme-green" ${themeClass==='theme-green'?'selected':''}>초록 미색</option>
                    <option value="theme-blue" ${themeClass==='theme-blue'?'selected':''}>파랑 미색</option>
                    <option value="theme-purple" ${themeClass==='theme-purple'?'selected':''}>보라 미색</option>
                </select>
                `}
                <button class="delete-group-btn" onclick="deleteGroup('${groupId}')">그룹 삭제</button>
            </div>
        </div>
        
        <ul class="todo-list" id="list-${groupId}"></ul>

        <div class="group-todo-adder">
            <input type="date" class="inline-todo-date">
            <input type="text" placeholder="이 그룹에 추가할 일을 바로 입력하세요" class="inline-todo-input">
            <button onclick="addTodoInline('${groupId}')">바로 추가</button>
        </div>
    `;

    mainContainer.appendChild(groupSection);
    updateEmptyNotice();

    const inlineInput = groupSection.querySelector('.inline-todo-input');
    inlineInput.addEventListener('keypress', function(e) {
        if (e.key === 'Enter') addTodoInline(groupId);
    });
}

function appendGroupToDropdown(groupId, groupName) {
    const groupHistorySelect = document.getElementById('groupHistorySelect');
    const newOption = document.createElement('option');
    newOption.value = groupId;
    newOption.textContent = `📁 ${groupName}`;
    groupHistorySelect.appendChild(newOption);
}

function enableEditGroup(titleElement) {
    if (titleElement.nextElementSibling && titleElement.nextElementSibling.classList.contains('edit-group-input')) {
        return;
    }

    const currentTitle = titleElement.textContent;
    const parentHeader = titleElement.parentElement;
    const groupId = parentHeader.parentElement.id;

    const editInput = document.createElement('input');
    editInput.type = 'text';
    editInput.className = 'edit-group-input';
    editInput.value = currentTitle;

    titleElement.style.display = 'none';
    parentHeader.insertBefore(editInput, titleElement);
    editInput.focus();

    function saveGroupTitle() {
        const updatedTitle = editInput.value.trim();
        if (updatedTitle === '') {
            alert('그룹 이름은 최소 한 글자 이상 입력되어야 합니다.');
            editInput.focus();
            return;
        }
        titleElement.textContent = updatedTitle;
        titleElement.style.display = 'block';
        editInput.remove();

        const selectBox = document.getElementById('groupHistorySelect');
        const options = selectBox.options;
        for (let i = 0; i < options.length; i++) {
            if (options[i].value === groupId) {
                options[i].textContent = `📁 ${updatedTitle}`;
                break;
            }
        }
    }

    editInput.addEventListener('keypress', function(e) {
        if (e.key === 'Enter') saveGroupTitle();
    });
    editInput.addEventListener('blur', function() {
        saveGroupTitle();
    });
}

// 2. 할 일 목록 아이템 주입 함수 (★ 마감 기한 문자열 조건부 렌더링 세분화)
function appendTodoItem(groupId, todoText, dueDateValue) {
    const targetListElement = document.getElementById(`list-${groupId}`);
    const currentDateTime = getCurrentDateTime();
    
    // 마감일 유무 가독성 레이아웃 분기
    let dueDateText = '마감일 지정 없음';
    let ddayBadgeHtml = '';
    
    if (dueDateValue) {
        dueDateText = `마감일: ${dueDateValue}`;
        ddayBadgeHtml = `<span class="dday-badge">${calculateDDay(dueDateValue)}</span>`;
    }

    const todoItem = document.createElement('li');
    todoItem.className = 'todo-item status-todo'; 
    todoItem.setAttribute('data-status', 'todo'); 

    // ★ 마감일 영역에 data-date 속성을 심고 click 이벤트 연동 (enableEditDueDate)
    todoItem.innerHTML = `
        <div class="todo-content">
            <span class="todo-text" onclick="enableEditTodo(this)">${todoText}</span>
            <div class="todo-date-info">
                <span class="todo-created">생성일: ${currentDateTime}</span>
                <span class="todo-duedate-clickable" data-date="${dueDateValue || ''}" onclick="enableEditDueDate(this)">
                    | <span class="duedate-value-text">${dueDateText}</span>${ddayBadgeHtml}
                </span>
            </div>
        </div>
        <div class="todo-actions">
            <select class="status-select" onchange="updateStatus(this)">
                <option value="todo" selected>미시작</option>
                <option value="doing">진행중</option>
                <option value="done">완성</option>
            </select>
            <button class="delete-todo-btn" onclick="deleteTodo(this)">&times;</button>
        </div>
    `;

    targetListElement.appendChild(todoItem);
    applyCurrentFilter();
}

// 3. ★ 마감 날짜를 목록 안에서 인라인으로 수정할 수 있게 해주는 기능 (추가됨)
function enableEditDueDate(clickableElement) {
    // 중복 호출 차단
    if (clickableElement.querySelector('.edit-todo-date')) return;

    const currentRawDate = clickableElement.getAttribute('data-date'); // 기존 YYYY-MM-DD 데이터값 확보
    const valueTextSpan = clickableElement.querySelector('.duedate-value-text');
    const ddayBadge = clickableElement.querySelector('.dday-badge');

    // 임시 날짜 선택기(input) 브라우저 렌더링 조립
    const dateInput = document.createElement('input');
    dateInput.type = 'date';
    dateInput.className = 'edit-todo-date';
    dateInput.value = currentRawDate;

    // 기존 텍스트 및 뱃지 숨김 처리 후 인풋 삽입
    valueTextSpan.style.display = 'none';
    if (ddayBadge) ddayBadge.style.display = 'none';
    clickableElement.appendChild(dateInput);
    dateInput.focus();

    // 마감일 변경사항 세이브 로직
    function saveDueDateChange() {
        const newDateValue = dateInput.value; // 새롭게 선택한 YYYY-MM-DD
        
        clickableElement.setAttribute('data-date', newDateValue);
        dateInput.remove(); // 임시 인풋 파기

        if (newDateValue) {
            valueTextSpan.textContent = `마감일: ${newDateValue}`;
            valueTextSpan.style.display = 'inline';
            
            // 디데이 뱃지 새로고침 연산 후 교체
            if (ddayBadge) {
                ddayBadge.textContent = calculateDDay(newDateValue);
                ddayBadge.style.display = 'inline';
            } else {
                const newBadge = document.createElement('span');
                newBadge.className = 'dday-badge';
                newBadge.textContent = calculateDDay(newDateValue);
                clickableElement.appendChild(newBadge);
            }
        } else {
            // 날짜를 비워두거나 선택 해제했을 때
            valueTextSpan.textContent = '마감일 지정 없음';
            valueTextSpan.style.display = 'inline';
            if (ddayBadge) ddayBadge.remove();
        }
    }

    // 엔터키 키맵 바인딩 및 포커스 아웃 바인딩
    dateInput.addEventListener('keypress', function(e) {
        if (e.key === 'Enter') saveDueDateChange();
    });
    dateInput.addEventListener('blur', function() {
        saveDueDateChange();
    });
}

function addTodoInline(groupId) {
    const groupElement = document.getElementById(groupId);
    const todoInput = groupElement.querySelector('.inline-todo-input');
    const dateInput = groupElement.querySelector('.inline-todo-date');

    const todoText = todoInput.value.trim();
    const dueDateValue = dateInput.value;

    if (todoText === '') {
        alert('할 일을 입력해주세요.');
        return;
    }

    appendTodoItem(groupId, todoText, dueDateValue);
    todoInput.value = '';
    dateInput.value = '';
}

function changeGroupTheme(groupId, newThemeClass) {
    const groupElement = document.getElementById(groupId);
    if (groupElement) {
        groupElement.classList.remove('theme-default', 'theme-yellow', 'theme-green', 'theme-blue', 'theme-purple');
        groupElement.classList.add(newThemeClass);
    }
}

function deleteGroup(groupId) {
    if (confirm('이 그룹과 그룹 내의 모든 할 일이 삭제됩니다. 진행하시겠습니까?')) {
        const groupElement = document.getElementById(groupId);
        if (groupElement) groupElement.remove();
        
        const selectBox = document.getElementById('groupHistorySelect');
        const options = selectBox.options;
        for (let i = 0; i < options.length; i++) {
            if (options[i].value === groupId) {
                selectBox.remove(i);
                break;
            }
        }
        selectBox.value = 'write_direct';
        toggleGroupInputMode('write_direct');
        updateEmptyNotice();
    }
}

function enableEditTodo(textElement) {
    if (textElement.nextElementSibling && textElement.nextElementSibling.classList.contains('edit-todo-input')) {
        return;
    }

    const currentText = textElement.textContent;
    const parentContainer = textElement.parentElement;

    const editInput = document.createElement('input');
    editInput.type = 'text';
    editInput.className = 'edit-todo-input';
    editInput.value = currentText;

    textElement.style.display = 'none';
    parentContainer.insertBefore(editInput, textElement);
    editInput.focus();

    function saveChanges() {
        const updatedText = editInput.value.trim();
        if (updatedText === '') {
            alert('할 일 내용은 한 글자 이상 입력되어야 합니다.');
            editInput.focus();
            return;
        }
        textElement.textContent = updatedText;
        textElement.style.display = 'block';
        editInput.remove();
    }

    editInput.addEventListener('keypress', function(e) {
        if (e.key === 'Enter') saveChanges();
    });
    editInput.addEventListener('blur', function() {
        saveChanges();
    });
}

function deleteTodo(button) {
    const todoItem = button.closest('.todo-item');
    todoItem.remove();
}

function updateStatus(selectElement) {
    const todoItem = selectElement.closest('.todo-item');
    const currentStatus = selectElement.value;

    todoItem.classList.remove('status-todo', 'status-doing', 'status-done');
    todoItem.setAttribute('data-status', currentStatus); 

    if (currentStatus === 'todo') {
        todoItem.classList.add('status-todo');
    } else if (currentStatus === 'doing') {
        todoItem.classList.add('status-doing');
    } else if (currentStatus === 'done') {
        todoItem.classList.add('status-done');
    }

    applyCurrentFilter();
}

function filterTodos(status, element) {
    currentFilter = status;
    const buttons = document.querySelectorAll('.filter-tabs-header .tab-btn');
    buttons.forEach(btn => btn.classList.remove('active'));
    element.classList.add('active');
    applyCurrentFilter();
}

function applyCurrentFilter() {
    const todoItems = document.querySelectorAll('.todo-item');
    todoItems.forEach(item => {
        const itemStatus = item.getAttribute('data-status');
        if (currentFilter === 'all' || itemStatus === currentFilter) {
            item.classList.remove('hidden'); 
        } else {
            item.classList.add('hidden');    
        }
    });
}

document.getElementById('topTodoInput').addEventListener('keypress', function(e) {
    if (e.key === 'Enter') handleSubmitTopForm();
});