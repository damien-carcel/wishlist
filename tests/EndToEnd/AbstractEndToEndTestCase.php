<?php

declare(strict_types=1);

namespace App\Tests\EndToEnd;

use Doctrine\DBAL\Connection;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Symfony\Component\HttpKernel\KernelInterface;

abstract class AbstractEndToEndTestCase extends WebTestCase
{
    /**
     * @param array<string, string> $options
     */
    protected static function bootKernel(array $options = []): KernelInterface
    {
        $options = array_merge($options, ['environment' => 'test']);

        return parent::bootKernel($options);
    }

    protected function setUp(): void
    {
        parent::setUp();

        /** @var Connection $databaseConnection */
        $databaseConnection = self::getContainer()->get('doctrine.dbal.default_connection');

        dump($databaseConnection->getConfiguration());
        // $databaseConnection->executeStatement('TRUNCATE TABLE "users"');

        self::ensureKernelShutdown();
    }
}
