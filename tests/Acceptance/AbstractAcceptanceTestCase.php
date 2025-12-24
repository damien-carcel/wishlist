<?php

declare(strict_types=1);

namespace App\Tests\Acceptance;

use Symfony\Bundle\FrameworkBundle\Test\KernelTestCase;
use Symfony\Component\HttpKernel\KernelInterface;

abstract class AbstractAcceptanceTestCase extends KernelTestCase
{
    /**
     * @param array<string, string> $options
     */
    protected static function bootKernel(array $options = []): KernelInterface
    {
        $options = array_merge($options, ['environment' => 'memory']);

        return parent::bootKernel($options);
    }
}
