<?php

declare(strict_types=1);

namespace App\Tests\EndToEnd;

use App\Tests\Shared\GetServiceTrait;
use Doctrine\DBAL\Connection;
use Symfony\Bundle\FrameworkBundle\KernelBrowser;
use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;

abstract class AbstractEndToEndTestCase extends WebTestCase
{
    use GetServiceTrait;

    protected KernelBrowser $client;

    protected function setUp(): void
    {
        $this->client = self::createClient();

        /** @var Connection $databaseConnection */
        $databaseConnection = self::getContainer()->get('doctrine.dbal.default_connection');

        dump($databaseConnection->getConfiguration());
        // $databaseConnection->executeStatement('TRUNCATE TABLE "whatever"');

        self::ensureKernelShutdown();
    }
}
