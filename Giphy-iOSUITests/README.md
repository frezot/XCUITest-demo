#  Что делает приложение

Тянет гифки, показывает бесконечной лентой.
Плюс умеет в поиск.

#  Что будет тестироваться
 
 - :white_check_mark: отображение ленты с непустым контентом
 - :white_check_mark: скролл и подгруз новых данных
 - :white_check_mark: scroll to top
 - :white_check_mark: успешный поиск
 - :white_check_mark:  очистка поискового запроса
 - :white_check_mark:  неуспешный поиск
 - :white_check_mark:  недоступность сервера

#  Что не будет тестироваться

Отображение сплэша точно нет смысла проверять, сценарий настолько базовый что не может быть незамечен если прилож хоть раз запустит человек.


#  Прочие ограничения

Не нашел как послать shake gesture из теста. Кажется стандартно [никак](https://ios.developreference.com/article/18203700/UI+Tests%3A+Simulate+a+shake+gesture+with+Swift). Такчто проверить undo-redo поиска, не получается.<br/>
Было бы правильным проверить  обработку ошибок сети, но вмешиваться в сетевой слой и выдумывать mock на свифте –  слишком трудозатратно. <br/>
Добвлю только базовый тест остуствия сети. <br/>
Чтобы сработал _правильно_ понадобится погасить сеть на хосте (или оборвать соединение на уровне proxy), или сломать `baseUrl` в `enum Constants` <br/>
В целом напрашивается необходимость менять эти константы из теста.  <br/>
Например через аргументы запуска, чтобы делать чтото вроде 
``` swift
app.launchArguments.append("-host")
app.launchArguments.append("failMe")
```
Но у меня лапки <br/>

# Troubleshooting

Локально возможна  ошибка `Neither element nor any descendant has keyboard focus`<br/>
__Решение__: В настройках симулятора Hardware → Keyboard снимаем все галочки<br/>
[Подробнее на SO](https://stackoverflow.com/questions/32184837/ui-testing-failure-neither-element-nor-any-descendant-has-keyboard-focus-on-se)<br/>
А еще помогает сменить  раскладку на EN (я серьезно).<br/>


Если `pod install` прошел успешно, а компиляция по-прежнему `Could not build Objective-C module 'Quick'`  – попробуй почистить DerivedData проекта. <br/>
[Источник](https://github.com/Quick/Quick/issues/262)<br/>

# Замечания к приложению

- отсутствует pull-to-refresh
- на поисковой ввод нужна хотябы небольшая задержка, не оч эффективно после каждой буквы перезапрашивать
