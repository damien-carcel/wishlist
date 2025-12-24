<?php

declare(strict_types=1);

namespace App\Tests\EndToEnd;

use PHPUnit\Framework\Attributes\Test;

final class ExampleTest extends AbstractEndToEndTestCase
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
