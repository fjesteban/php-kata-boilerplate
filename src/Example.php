<?php

namespace App;

class Example
{
    public function add(int ...$operators): int
    {
        return array_reduce($operators, function($operator, $carry) {
            return $carry + $operator;
        });
    }
}
