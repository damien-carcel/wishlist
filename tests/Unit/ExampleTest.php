<?php

declare(strict_types=1);

namespace App\Tests\Unit;

use PHPUnit\Framework\Attributes\Test;
use PHPUnit\Framework\TestCase;

final class ExampleTest extends TestCase
{
    #[Test]
    public function itSumsTwoNumbers(): void
    {
        $class = new class {
            public function sum(int $a, int $b): int
            {
                return $a + $b;
            }
        };

        self::assertSame(2, $class->sum(1, 1));
    }
}
