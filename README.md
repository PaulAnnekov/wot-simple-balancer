Balancer
=========

S&S (Simple and stupid) balancer for WOT.

How to run
-------------

  - Run `vagrant up` in current folder.
  - Wait some time for VM up and provisioning.
  - When VM will be successfully provisioned run `vagrant ssh`.
  - After connecting to VM run `balancer -h` in terminal to see usage guide.
  - Run `balancer -a your-app-id` to start balancer.

Algorithm
---------
<english-mode-off /> :)
 
Алгоритм основан на подсчёте балансных весов каждого танка и подбора равных оппонентов с небольшим отклонением (10-20%).

Балансный вес танка рассчитывается по следующей формуле:

`(gun_damage_min + gun_damage_max + max_health) * (mark_of_mastery / 16 + 1)`

**Знак классности** (`mark_of_mastery`) является коэффициентом, который увеличивает вес танка. Это обосновано тем, что более продвинутый геймер чаще попадает в нужные точки танков противника и знает как нужно ставить свой танк относительно противника.

Краткое описание алгоритма:

  - Считаем балансные веса каждого танка.
  - Выбираем из первой очереди танк и ищем во второй очереди оппонента, который имеет баланс близкий к выбранному танку с погрешностью в 10%.
  - Если мы нашли оппонента, то добавляем оба танка в команды.
  - Если не нашли, то заново выбираем случайный танк и продолжаем поиск увеличивая допустимую погрешность на 10%.

Алгоритм сбора данных:

  - Заранее запрашиваем все танки игры и кешируем их.
  - Выбираем из топа кланов десятку с самым большим количеством провинций.
  - Из десяти кланов случайно выбираем 2, у которых количество пользователей больше 30 (чтобы было что балансировать).
  - Получаем всех пользователей этих двух кланов.
  - Получаем танки первых 100 пользователей. Этого более чем достаточно для балансировки.
  - Фильтруем полученный список танков оставляя только танки 4-6 левелов.
  - Выбираем по одному случайному танку для каждого аккаунта.
  - Запрашиваем информацию по характеристикам отобранных танков.

License
-------

    Copyright 2014 Paul Annekov

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.