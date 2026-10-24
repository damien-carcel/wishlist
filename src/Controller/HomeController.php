<?php

declare(strict_types=1);

namespace App\Controller;

use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpKernel\Attribute\AsController;
use Symfony\Component\Routing\Attribute\Route;

#[AsController]
#[Route(path: '/', name: 'home'),]
final class HomeController extends AbstractController
{
    public function __construct(private readonly EntityManagerInterface $entityManager)
    {
    }

    public function __invoke(): Response
    {
        $connected = false;
        $error = 'Unable to fetch from database.';
        try {
            try {
                $result = $this->entityManager->getConnection()->executeQuery('SELECT 1')->fetchOne();
                if (null !== $result) {
                    $connected = true;
                    $error = '';
                }
            } catch (\Throwable $exception) {
                $error = $exception->getMessage();
            }

            return $this->render(
                'home/index.html.twig',
                [
                    'connected' => $connected ? 'OK' : 'KO',
                    'error' => $error,
                ],
            );
        } catch (\Exception $exception) {
            return $this->render(
                'home/index.html.twig',
                [
                    'connected' => false,
                    'error' => $exception->getMessage(),
                ],
            );
        }
    }
}
