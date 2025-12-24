<?php

declare(strict_types=1);

namespace App\Tests\Integration;

use PHPUnit\Framework\Attributes\Group;
use PHPUnit\Framework\Attributes\Test;

final class ExampleTest extends AbstractIntegrationTestCase
{
    #[Test]
    #[Group('with-in-memory-adapters')]
    #[Group('with-production-adapters')]
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
