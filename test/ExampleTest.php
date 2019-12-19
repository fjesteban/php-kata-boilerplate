<?php

namespace Test;

use App\Example;
use PHPUnit\Framework\TestCase;

class ExampleTest extends TestCase
{

    public function testAdd()
    {
        $example = new Example();
        $this->assertEquals(2, $example->add(1,1));
    }
}
